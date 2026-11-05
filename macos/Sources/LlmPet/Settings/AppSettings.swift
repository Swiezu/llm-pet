import AppKit
import IOKit.ps
import Observation

@MainActor
@Observable
final class AppSettings {
    static let shared = AppSettings()
    static let fpsOptions = [15, 30, 60, 120, 144, 165, 240]
    static let vsyncFPS = 0
    static let bubbleFonts: ClosedRange<Double> = 10...22
    static let bubbleWidths: ClosedRange<Double> = 160...800
    static let bubbleHeights: ClosedRange<Int> = 2...30
    static let expandedWidths: ClosedRange<Double> = 300...2000
    static let expandedHeights: ClosedRange<Int> = 5...120
    static let bubbleCounts: ClosedRange<Int> = 0...10
    static let petScales: ClosedRange<Double> = 0.5...2
    static let speeds: ClosedRange<Double> = 0.25...3
    static let fastSpeeds: ClosedRange<Double> = 1...5
    private static let palette = ["#FFD9A8", "#B8E1FF", "#C9F2C7", "#F7C6E0", "#E2D4FF", "#FFF3A8", "#3B4A6B", "#7A2E3A"]

    var fpsPower: Int {
        didSet { UserDefaults.standard.set(fpsPower, forKey: "fpsPower") }
    }

    var fpsBattery: Int {
        didSet { UserDefaults.standard.set(fpsBattery, forKey: "fpsBattery") }
    }

    var animationSpeed: Double {
        didSet { UserDefaults.standard.set(animationSpeed, forKey: "animationSpeed") }
    }

    var fastSpeed: Double {
        didSet { UserDefaults.standard.set(fastSpeed, forKey: "fastSpeed") }
    }

    var fastMode: Bool {
        didSet { UserDefaults.standard.set(fastMode, forKey: "fastMode") }
    }

    var animationsEnabled: Bool {
        didSet { UserDefaults.standard.set(animationsEnabled, forKey: "animationsEnabled") }
    }

    private(set) var onBattery = AppSettings.batteryPowered()

    var displayFPS = NSScreen.main?.maximumFramesPerSecond ?? 60

    var availableFPS: [Int] { Self.fpsOptions.filter { $0 <= displayFPS } + [Self.vsyncFPS] }

    var vsync: Bool { (onBattery ? fpsBattery : fpsPower) == Self.vsyncFPS }

    var fps: Int {
        let value = onBattery ? fpsBattery : fpsPower
        return value == Self.vsyncFPS ? displayFPS : min(value, displayFPS)
    }

    var speed: Double { fastMode ? fastSpeed : animationSpeed }

    var bubbleFont: Double {
        didSet { UserDefaults.standard.set(bubbleFont, forKey: "bubbleFont") }
    }

    var bubbleWidth: Double {
        didSet { UserDefaults.standard.set(bubbleWidth, forKey: "bubbleWidth") }
    }

    var bubbleLines: Int {
        didSet { UserDefaults.standard.set(bubbleLines, forKey: "bubbleLines") }
    }

    var expandedWidth: Double {
        didSet { UserDefaults.standard.set(expandedWidth, forKey: "expandedWidth") }
    }

    var expandedLines: Int {
        didSet { UserDefaults.standard.set(expandedLines, forKey: "expandedLines") }
    }

    var bubbleCount: Int {
        didSet { UserDefaults.standard.set(bubbleCount, forKey: "bubbleCount") }
    }

    var newestFirst: Bool {
        didSet { UserDefaults.standard.set(newestFirst, forKey: "newestFirst") }
    }

    var petScale: Double {
        didSet { UserDefaults.standard.set(petScale, forKey: "petScale") }
    }

    var channels: [Channel] {
        didSet {
            save()
            let live = Set(channels.filter { !$0.muted }.map(\.id))
            Pet.shared.bubbles.drop { !live.contains($0) }
            for channel in channels {
                guard let old = oldValue.first(where: { $0.id == channel.id }), old.muted != channel.muted else { continue }
                Pet.shared.perform(channel.muted ? .mute : .unmute)
            }
        }
    }

    var language: Language? {
        didSet { UserDefaults.standard.set(language?.rawValue, forKey: "language") }
    }

    var lang: Language { language ?? .en }

    var main: Channel { channels.first(where: \.isMain) ?? Channel(id: Channel.mainID, name: "Main", color: "#FFFFFF") }

    private init() {
        let defaults = UserDefaults.standard
        let legacy = defaults.integer(forKey: "fps")
        let fps = legacy > 0 ? Self.nearest(legacy) : 30
        fpsPower = defaults.object(forKey: "fpsPower").map { _ in Self.nearest(defaults.integer(forKey: "fpsPower")) } ?? fps
        fpsBattery = defaults.object(forKey: "fpsBattery").map { _ in Self.nearest(defaults.integer(forKey: "fpsBattery")) } ?? fps
        let speed = defaults.double(forKey: "animationSpeed")
        animationSpeed = Self.speeds.contains(speed) ? speed : 1
        let fast = defaults.double(forKey: "fastSpeed")
        fastSpeed = Self.fastSpeeds.contains(fast) ? fast : 2
        fastMode = defaults.object(forKey: "fastMode") as? Bool ?? false
        animationsEnabled = defaults.object(forKey: "animationsEnabled") as? Bool ?? true
        let font = UserDefaults.standard.double(forKey: "bubbleFont")
        bubbleFont = Self.bubbleFonts.contains(font) ? font : 13
        let width = UserDefaults.standard.double(forKey: "bubbleWidth")
        bubbleWidth = Self.bubbleWidths.contains(width) ? width : 300
        let lines = UserDefaults.standard.integer(forKey: "bubbleLines")
        bubbleLines = Self.bubbleHeights.contains(lines) ? lines : 8
        let expandedWidth = UserDefaults.standard.double(forKey: "expandedWidth")
        self.expandedWidth = Self.expandedWidths.contains(expandedWidth) ? expandedWidth : 800
        let expandedLines = UserDefaults.standard.integer(forKey: "expandedLines")
        self.expandedLines = Self.expandedHeights.contains(expandedLines) ? expandedLines : 40
        let bubbleCount = UserDefaults.standard.object(forKey: "bubbleCount") as? Int ?? 2
        self.bubbleCount = Self.bubbleCounts.contains(bubbleCount) ? bubbleCount : 2
        newestFirst = UserDefaults.standard.object(forKey: "newestFirst") as? Bool ?? false
        let scale = UserDefaults.standard.double(forKey: "petScale")
        petScale = Self.petScales.contains(scale) ? scale : 1
        language = UserDefaults.standard.string(forKey: "language").flatMap(Language.init)
        let stored = UserDefaults.standard.data(forKey: "channels").flatMap { try? JSONDecoder().decode([Channel].self, from: $0) } ?? []
        channels = stored.contains(where: \.isMain) ? stored : [Channel(id: Channel.mainID, name: "Main", color: "#FFFFFF")] + stored
        if let source = IOPSNotificationCreateRunLoopSource({ _ in
            MainActor.assumeIsolated { AppSettings.shared.onBattery = AppSettings.batteryPowered() }
        }, nil)?.takeRetainedValue() {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
        }
    }

    private static func nearest(_ fps: Int) -> Int {
        fps == vsyncFPS ? fps : fpsOptions.min { abs($0 - fps) < abs($1 - fps) } ?? 30
    }

    private static func batteryPowered() -> Bool {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(), let type = IOPSGetProvidingPowerSourceType(info)?.takeUnretainedValue() else { return false }
        return type as String == kIOPMBatteryPowerKey
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
