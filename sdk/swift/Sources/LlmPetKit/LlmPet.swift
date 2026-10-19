import Foundation

public enum LlmPetError: Error, Sendable {
    case notRunning
    case server(status: Int, message: String)
}

public struct LlmPetStatus: Decodable, Sendable {
    public let enabled: Bool
    public let action: String
    public let speaking: Bool
    public let fps: Int
}

public struct LlmPetAction: Decodable, Sendable {
    public let name: String
    public let title: String
    public let seconds: Double?
}

public struct LlmPetChannel: Decodable, Sendable {
    public let id: String
    public let name: String
    public let color: String
    public let muted: Bool
    public let main: Bool
}

public struct LlmPet: Sendable {
    public static let serverFile = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Application Support/llm-pet/server.json")

    private struct Info: Decodable {
        let port: Int
        let token: String
    }

    private struct Failure: Decodable {
        let error: String
    }

    private let file: URL

    public init(serverFile: URL = LlmPet.serverFile) {
        file = serverFile
    }

    @discardableResult
    public func say(_ text: String, channel: String? = nil, animation: String? = nil, seconds: Double? = nil) async throws -> Bool {
        var body: [String: Any] = ["text": text]
        if let channel { body["channel"] = channel }
        if let animation { body["animation"] = animation }
        if let seconds { body["seconds"] = seconds }
        let result = try JSONSerialization.jsonObject(with: try await send("POST", "/say", body)) as? [String: Any]
        return result?["shown"] as? Bool ?? false
    }

    public func action(_ name: String) async throws {
        _ = try await send("POST", "/action", ["name": name])
    }

    public func actions() async throws -> [LlmPetAction] {
        try decode([String: [LlmPetAction]].self, try await send("GET", "/actions", nil))["actions"] ?? []
    }

    public func channels() async throws -> [LlmPetChannel] {
        try decode([String: [LlmPetChannel]].self, try await send("GET", "/channels", nil))["channels"] ?? []
    }

    @discardableResult
    public func addChannel(_ name: String, color: String? = nil) async throws -> LlmPetChannel? {
        var body: [String: Any] = ["name": name]
        if let color { body["color"] = color }
        return try decode([String: LlmPetChannel].self, try await send("POST", "/channels", body))["channel"]
    }

    public func removeChannel(_ channel: String) async throws {
        _ = try await send("DELETE", "/channels/\(channel.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))) ?? channel)", nil)
    }

    public func show() async throws {
        _ = try await send("POST", "/show", nil)
    }

    public func hide() async throws {
        _ = try await send("POST", "/hide", nil)
    }

    public func status() async throws -> LlmPetStatus {
        try decode(LlmPetStatus.self, try await send("GET", "/status", nil))
    }

    private func decode<T: Decodable>(_ type: T.Type, _ data: Data) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }

    private func send(_ method: String, _ path: String, _ body: [String: Any]?) async throws -> Data {
        guard let data = try? Data(contentsOf: file), let info = try? JSONDecoder().decode(Info.self, from: data), let url = URL(string: "http://127.0.0.1:\(info.port)\(path)") else { throw LlmPetError.notRunning }
        var request = URLRequest(url: url, timeoutInterval: 3)
        request.httpMethod = method
        request.setValue("Bearer \(info.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body { request.httpBody = try JSONSerialization.data(withJSONObject: body) }
        let (result, response): (Data, URLResponse)
        do {
            (result, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw LlmPetError.notRunning
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw LlmPetError.server(status: status, message: (try? JSONDecoder().decode(Failure.self, from: result).error) ?? "HTTP \(status)")
        }
        return result
    }
}
