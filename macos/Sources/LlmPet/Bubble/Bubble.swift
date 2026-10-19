import AppKit
import Observation
import SwiftUI

@MainActor
@Observable
final class Bubble {
    static let lines = 8
    private static let baseFont: CGFloat = 13
    private static let baseWidth: CGFloat = 300

    private(set) var text: String?
    private(set) var tail: CGFloat = 0
    private(set) var below = false
    private(set) var pointing = true
    private(set) var waiting = 0
    private(set) var shown = false
    private(set) var width: CGFloat = 0
    private(set) var count = 0
    private(set) var background = Color.white
    private(set) var foreground = Color.black.opacity(0.85)
    private(set) var link: URL?
    private(set) var linkTitle = ""
    private(set) var forever = false
    private(set) var progress: Double = 0
    private(set) var fontSize = CGFloat(AppSettings.shared.bubbleFont)

    var font: NSFont { .monospacedSystemFont(ofSize: fontSize, weight: .semibold) }
    var linkFont: NSFont { .monospacedSystemFont(ofSize: max(9, fontSize - 2), weight: .semibold) }
    var zoom: CGFloat { fontSize / Self.baseFont }

    private enum Phase { case idle, typing, reading, erasing, hiding }

    @ObservationIgnored var offset: CGFloat?
    @ObservationIgnored private var phase = Phase.idle
    @ObservationIgnored private var phaseStart = Date.now
    @ObservationIgnored private var readTime: TimeInterval = 4
    @ObservationIgnored private var window: NSPanel?
    @ObservationIgnored private var host: NSHostingController<BubbleView>?

    func say(_ message: String, for seconds: TimeInterval? = nil, link: URL? = nil, background: Color = .white, foreground: Color = .black.opacity(0.85)) {
        self.background = background
        self.foreground = foreground
        self.link = link
        linkTitle = link.map(Self.title) ?? ""
        let char = "M".size(withAttributes: [.font: font]).width
        let capacity = Int(Self.baseWidth * zoom / char * CGFloat(Self.lines) * 0.85)
        let text = message.count > capacity ? String(message.prefix(capacity - 1)).trimmingCharacters(in: .whitespaces) + "…" : message
        self.text = text
        measure()
        count = 0
        shown = false
        phase = .typing
        phaseStart = .now.addingTimeInterval(0.18)
        readTime = seconds ?? min(8, max(2.5, 2 + Double(text.count) / 25))
        forever = readTime.isInfinite
        progress = 0
        Task {
            try? await Task.sleep(for: .milliseconds(40))
            shown = true
        }
    }

    var finished: Bool { text == nil }

    func update(_ now: Date) {
        guard let text else { return }
        let total = text.count
        let elapsed = max(0, now.timeIntervalSince(phaseStart))
        switch phase {
        case .idle:
            break
        case .typing:
            let next = min(total, Int(elapsed * max(90, Double(total) / 1.4)))
            if next != count { count = next }
            if next == total {
                phase = .reading
                phaseStart = now
            }
        case .reading:
            let next = readTime.isFinite ? min(1, elapsed / readTime) : 0
            if abs(next - progress) > 0.002 || next == 1 { progress = next }
            if elapsed >= readTime {
                phase = .erasing
                phaseStart = now
            }
        case .erasing:
            let next = max(0, total - Int(elapsed * max(160, Double(total) / 0.6)))
            if next != count { count = next }
            if next == 0 {
                phase = .hiding
                shown = false
                phaseStart = now
            }
        case .hiding:
            if elapsed >= 0.25 {
                self.text = nil
                phase = .idle
            }
        }
    }

    func dismiss() {
        guard let text, phase == .typing || phase == .reading else { return }
        progress = 1
        phase = .erasing
        phaseStart = .now.addingTimeInterval(-Double(text.count - count) / max(160, Double(text.count) / 0.6))
    }

    func open() {
        guard let link else { return }
        NSWorkspace.shared.open(link)
        dismiss()
    }

    private static func title(_ url: URL) -> String {
        if url.isFileURL { return url.lastPathComponent + " ↗" }
        if let host = url.host(), ["http", "https"].contains(url.scheme?.lowercased()) { return host.replacing(/^www\./, with: "") + " ↗" }
        return (url.scheme ?? "") + "://" + (url.host() ?? "") + " ↗"
    }

    private func measure() {
        let widest = (text ?? "").split(separator: "\n", omittingEmptySubsequences: false).map { String($0).size(withAttributes: [.font: font]).width }.max() ?? 0
        let linkWidth = link == nil ? 0 : (linkTitle as NSString).size(withAttributes: [.font: linkFont]).width
        width = min(Self.baseWidth * zoom, ceil(max(widest, linkWidth)) + 2)
    }

    func layout(below: Bool, pointing: Bool, waiting: Int) -> NSSize {
        let size = CGFloat(AppSettings.shared.bubbleFont)
        if size != fontSize {
            fontSize = size
            measure()
        }
        if below != self.below { self.below = below }
        if pointing != self.pointing { self.pointing = pointing }
        if waiting != self.waiting { self.waiting = waiting }
        if window == nil {
            let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
            panel.level = .statusBar
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.ignoresMouseEvents = true
            let host = NSHostingController(rootView: BubbleView(bubble: self))
            host.sizingOptions = []
            panel.contentViewController = host
            window = panel
            self.host = host
        }
        let fit = host?.sizeThatFits(in: NSSize(width: 400, height: 1000)) ?? .zero
        return NSSize(width: ceil(fit.width), height: ceil(fit.height))
    }

    func move(to frame: NSRect, tail: CGFloat) {
        guard let window else { return }
        if abs(tail - self.tail) > 0.5 { self.tail = tail }
        let frame = frame.integral
        if window.frame != frame { window.setFrame(frame, display: true) }
        let interactive = forever || link != nil
        if window.ignoresMouseEvents == interactive { window.ignoresMouseEvents = !interactive }
        if !window.isVisible { window.orderFrontRegardless() }
    }

    func close() {
        window?.orderOut(nil)
        window = nil
        host = nil
    }
}
