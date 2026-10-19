import AppKit
import Observation
import SwiftUI

@MainActor
@Observable
final class Bubble {
    static let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
    static let lines = 8
    private static let maxWidth: CGFloat = 300

    private(set) var text: String?
    private(set) var tail: CGFloat = 0
    private(set) var below = false
    private(set) var shown = false
    private(set) var width: CGFloat = 0
    private(set) var count = 0
    private(set) var background = Color.white
    private(set) var foreground = Color.black.opacity(0.85)

    private enum Phase { case idle, typing, reading, erasing, hiding }

    @ObservationIgnored private var phase = Phase.idle
    @ObservationIgnored private var phaseStart = Date.now
    @ObservationIgnored private var readTime: TimeInterval = 4
    @ObservationIgnored private var window: NSPanel?
    @ObservationIgnored private var host: NSHostingController<BubbleView>?

    func say(_ message: String, for seconds: TimeInterval? = nil, background: Color = .white, foreground: Color = .black.opacity(0.85)) {
        self.background = background
        self.foreground = foreground
        let char = "M".size(withAttributes: [.font: Self.font]).width
        let capacity = Int(Self.maxWidth / char * CGFloat(Self.lines) * 0.85)
        let text = message.count > capacity ? String(message.prefix(capacity - 1)).trimmingCharacters(in: .whitespaces) + "…" : message
        let widest = text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0).size(withAttributes: [.font: Self.font]).width }.max() ?? 0
        width = min(Self.maxWidth, ceil(widest) + 2)
        self.text = text
        count = 0
        shown = false
        phase = .typing
        phaseStart = .now.addingTimeInterval(0.18)
        readTime = seconds ?? min(8, max(2.5, 2 + Double(text.count) / 25))
        Task {
            try? await Task.sleep(for: .milliseconds(40))
            shown = true
        }
    }

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

    func place(on screen: NSRect, center: CGFloat, bottom: CGFloat, head: CGFloat) {
        guard text != nil else {
            window?.orderOut(nil)
            return
        }
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
        guard let window, let host else { return }
        let fit = host.sizeThatFits(in: NSSize(width: 400, height: 1000))
        let size = NSSize(width: ceil(fit.width), height: ceil(fit.height))
        let below = head + size.height > screen.maxY
        let originX = min(max(center - size.width / 2, screen.minX + 4), screen.maxX - size.width - 4)
        let tail = center - originX
        if abs(tail - self.tail) > 0.5 { self.tail = tail }
        if below != self.below { self.below = below }
        let frame = NSRect(x: originX, y: below ? max(screen.minY, bottom - size.height + 10) : head, width: size.width, height: size.height).integral
        if window.frame != frame { window.setFrame(frame, display: true) }
        if !window.isVisible { window.orderFrontRegardless() }
    }

    func close() {
        window?.orderOut(nil)
        window = nil
        host = nil
    }
}
