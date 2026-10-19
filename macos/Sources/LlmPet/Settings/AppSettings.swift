import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    static let shared = AppSettings()
    static let fpsOptions = [12, 24, 30, 60, 120]
    static let bubbleFonts: ClosedRange<Double> = 10...22
    static let petScales: ClosedRange<Double> = 0.5...2
    private static let palette = ["#FFD9A8", "#B8E1FF", "#C9F2C7", "#F7C6E0", "#E2D4FF", "#FFF3A8", "#3B4A6B", "#7A2E3A"]

    var fps: Int {
        didSet { UserDefaults.standard.set(fps, forKey: "fps") }
    }

    var bubbleFont: Double {
        didSet { UserDefaults.standard.set(bubbleFont, forKey: "bubbleFont") }
    }

    var petScale: Double {
        didSet { UserDefaults.standard.set(petScale, forKey: "petScale") }
    }

    var channels: [Channel] {
        didSet { save() }
    }

    var language: Language? {
        didSet { UserDefaults.standard.set(language?.rawValue, forKey: "language") }
    }

    var lang: Language { language ?? .en }

    var main: Channel { channels.first(where: \.isMain) ?? Channel(id: Channel.mainID, name: "Main", color: "#FFFFFF") }

    private init() {
        let fps = UserDefaults.standard.integer(forKey: "fps")
        self.fps = Self.fpsOptions.contains(fps) ? fps : 30
        let font = UserDefaults.standard.double(forKey: "bubbleFont")
        bubbleFont = Self.bubbleFonts.contains(font) ? font : 13
        let scale = UserDefaults.standard.double(forKey: "petScale")
        petScale = Self.petScales.contains(scale) ? scale : 1
        language = UserDefaults.standard.string(forKey: "language").flatMap(Language.init)
        let stored = UserDefaults.standard.data(forKey: "channels").flatMap { try? JSONDecoder().decode([Channel].self, from: $0) } ?? []
        channels = stored.contains(where: \.isMain) ? stored : [Channel(id: Channel.mainID, name: "Main", color: "#FFFFFF")] + stored
    }

    func channel(_ key: String?) -> Channel? {
        guard let key = key?.trimmingCharacters(in: .whitespaces), !key.isEmpty else { return main }
        return channels.first { $0.id == key } ?? channels.first { $0.name.localizedCaseInsensitiveCompare(key) == .orderedSame }
    }

    @discardableResult
    func addChannel(name: String? = nil, color: String? = nil) -> Channel {
        let used = Set(channels.map(\.color))
        let channel = Channel(
            id: UUID().uuidString.prefix(8).lowercased(),
            name: name ?? tr("Channel \(channels.count)", "Kanał \(channels.count)"),
            color: color ?? Self.palette.first { !used.contains($0) } ?? Self.palette.randomElement() ?? "#FFFFFF"
        )
        channels.append(channel)
        return channel
    }

    func removeChannel(_ id: String) {
        channels.removeAll { $0.id == id && !$0.isMain }
    }

    private func save() {
        UserDefaults.standard.set(try? JSONEncoder().encode(channels), forKey: "channels")
    }
}
