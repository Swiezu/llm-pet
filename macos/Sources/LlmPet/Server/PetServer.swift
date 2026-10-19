import Foundation
import Network

@MainActor
final class PetServer {
    static let shared = PetServer()

    private static let maxRequest = 64 * 1024
    private var listener: NWListener?
    private let token = (0..<32).map { _ in String(format: "%02x", UInt8.random(in: 0...255)) }.joined()

    func start() {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: .ipv4(.loopback), port: .any)
        guard let listener = try? NWListener(using: parameters) else { return }
        listener.stateUpdateHandler = { [weak self] state in
            MainActor.assumeIsolated {
                if case .ready = state, let port = listener.port?.rawValue { self?.publish(port: port) }
            }
        }
        listener.newConnectionHandler = { [weak self] connection in
            MainActor.assumeIsolated { self?.accept(connection) }
        }
        listener.start(queue: .main)
        self.listener = listener
    }

    func stop() {
        listener?.cancel()
        try? FileManager.default.removeItem(at: ServerInfo.url)
    }

    private func publish(port: UInt16) {
        ServerInfo(port: port, token: token, pid: ProcessInfo.processInfo.processIdentifier).save()
    }

    private func accept(_ connection: NWConnection) {
        connection.start(queue: .main)
        receive(connection, buffer: Data())
    }

    private func receive(_ connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: Self.maxRequest) { [weak self] data, _, complete, error in
            MainActor.assumeIsolated {
                guard let self else { return }
                var buffer = buffer
                if let data { buffer.append(data) }
                if let request = Request(buffer) {
                    self.reply(connection, self.handle(request))
                } else if error != nil || complete || buffer.count > Self.maxRequest {
                    self.reply(connection, .error(400, "malformed request"))
                } else {
                    self.receive(connection, buffer: buffer)
                }
            }
        }
    }

    private func reply(_ connection: NWConnection, _ response: Response) {
        connection.send(content: response.data, completion: .contentProcessed { _ in connection.cancel() })
    }

    private func handle(_ request: Request) -> Response {
        guard request.headers["authorization"] == "Bearer \(token)" else { return .error(401, "missing or invalid token") }
        let pet = Pet.shared
        let settings = AppSettings.shared
        let path = request.path.split(separator: "?").first.map(String.init) ?? request.path
        switch (request.method, path) {
        case ("GET", "/status"):
            return .json(["enabled": pet.enabled, "action": pet.action.rawValue, "speaking": pet.bubbles.speaking, "bubbles": pet.bubbles.active.count, "queued": pet.bubbles.queued, "fps": settings.fps])
        case ("GET", "/actions"):
            return .json(["actions": Action.allCases.map(Self.describe)])
        case ("GET", "/channels"):
            return .json(["channels": settings.channels.map(Self.describe)])
        case ("POST", "/channels"):
            guard let name = (request.json?["name"] as? String)?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return .error(400, "field name is required") }
            guard !settings.channels.contains(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) else { return .error(409, "a channel with this name already exists") }
            let color = request.json?["color"] as? String
            if let color, color.wholeMatch(of: /#?[0-9A-Fa-f]{6}/) == nil { return .error(400, "color must be #RRGGBB") }
            return .json(["channel": Self.describe(settings.addChannel(name: name, color: color.map { "#" + $0.trimmingPrefix("#").uppercased() }))], status: 201)
        case ("DELETE", let path) where path.hasPrefix("/channels/"):
            let key = String(path.dropFirst("/channels/".count)).removingPercentEncoding ?? ""
            guard let channel = settings.channel(key), !key.isEmpty else { return .error(404, "unknown channel") }
            guard !channel.isMain else { return .error(400, "the main channel cannot be deleted") }
            settings.removeChannel(channel.id)
            return .json(["ok": true])
        case ("POST", "/say"):
            guard let body = request.json, let text = body["text"] as? String, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .error(400, "field text is required") }
            guard let channel = settings.channel(body["channel"] as? String) else { return .error(404, "unknown channel, available: \(settings.channels.map(\.name).joined(separator: ", "))") }
            var animation: Action?
            if let name = body["animation"] as? String {
                guard let action = Action(rawValue: name) else { return Self.unknownAction }
                animation = action
            }
            var link: URL?
            if let value = body["link"] as? String, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                guard let url = Self.link(value) else { return .error(400, "link must be a URL with a scheme (https://, file://, myapp://) or an absolute path") }
                link = url
            }
            guard pet.enabled else { return .error(409, "pet is hidden") }
            guard !channel.muted else { return .json(["ok": true, "shown": false, "muted": true, "channel": channel.id]) }
            guard let queued = pet.say(text, for: (body["seconds"] as? Double).map { $0 == 0 ? .infinity : min(3600, max(1, $0)) }, link: link, animation: animation, on: channel) else { return .error(429, "too many bubbles waiting (\(BubbleStack.maxQueue)), try again later") }
            return .json(["ok": true, "shown": true, "queued": queued, "channel": channel.id])
        case ("POST", "/action"):
            guard let name = request.json?["name"] as? String, let action = Action(rawValue: name) else { return Self.unknownAction }
            guard pet.enabled else { return .error(409, "pet is hidden") }
            pet.perform(action)
            return .json(["ok": true])
        case ("POST", "/show"), ("POST", "/hide"):
            pet.setEnabled(path == "/show")
            return .json(["ok": true])
        default:
            return .error(404, "unknown endpoint")
        }
    }

    private static var unknownAction: Response {
        .error(400, "unknown animation, available: \(Action.allCases.map(\.rawValue).joined(separator: ", "))")
    }

    private static func link(_ value: String) -> URL? {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("/") || value.hasPrefix("~") { return URL(fileURLWithPath: (value as NSString).expandingTildeInPath) }
        guard let url = URL(string: value), let scheme = url.scheme, !scheme.isEmpty else { return nil }
        return url
    }

    private static func describe(_ action: Action) -> [String: Any] {
        ["name": action.rawValue, "title": action.title(.en), "seconds": action.duration.isFinite ? (action.duration * 100).rounded() / 100 : NSNull()]
    }

    private static func describe(_ channel: Channel) -> [String: Any] {
        ["id": channel.id, "name": channel.name, "color": channel.color, "muted": channel.muted, "main": channel.isMain]
    }
}

private struct Request {
    let method: String
    let path: String
    let headers: [String: String]
    let body: Data

    var json: [String: Any]? { try? JSONSerialization.jsonObject(with: body) as? [String: Any] }

    init?(_ data: Data) {
        guard let end = data.range(of: Data("\r\n\r\n".utf8)), let head = String(data: data[..<end.lowerBound], encoding: .utf8) else { return nil }
        let lines = head.components(separatedBy: "\r\n")
        let start = lines.first?.split(separator: " ") ?? []
        guard start.count >= 2 else { return nil }
        var headers: [String: String] = [:]
        for line in lines.dropFirst() {
            guard let colon = line.firstIndex(of: ":") else { continue }
            headers[line[..<colon].lowercased()] = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        }
        let length = Int(headers["content-length"] ?? "0") ?? 0
        let body = data[end.upperBound...]
        guard body.count >= length else { return nil }
        method = String(start[0])
        path = String(start[1])
        self.headers = headers
        self.body = Data(body.prefix(length))
    }
}

private struct Response {
    let status: Int
    let body: Data

    static func json(_ object: [String: Any], status: Int = 200) -> Response {
        Response(status: status, body: (try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])) ?? Data())
    }

    static func error(_ status: Int, _ message: String) -> Response {
        json(["error": message], status: status)
    }

    var data: Data {
        let reason = HTTPURLResponse.localizedString(forStatusCode: status)
        var data = Data("HTTP/1.1 \(status) \(reason)\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n".utf8)
        data.append(body)
        return data
    }
}
