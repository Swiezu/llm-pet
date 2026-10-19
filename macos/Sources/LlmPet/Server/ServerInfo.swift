import Foundation

struct ServerInfo: Codable {
    static let url = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Application Support/llm-pet/server.json")

    let port: UInt16
    let token: String
    let pid: Int32

    func save() {
        let directory = Self.url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        guard let data = try? JSONEncoder().encode(self) else { return }
        FileManager.default.createFile(atPath: Self.url.path, contents: data, attributes: [.posixPermissions: 0o600])
    }
}
