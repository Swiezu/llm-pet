import AppKit
import Observation
import SwiftUI

enum BubbleStyle: String, CaseIterable {
    case bubble, left, right
}

@MainActor
@Observable
final class Bubble {
    private static let baseFont: CGFloat = 13
    private static let foldTime: TimeInterval = 0.35
    private static let sizer = NSHostingController(rootView: AnyView(EmptyView()))

    private(set) var text: String?
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var style = BubbleStyle.bubble
    private(set) var tail: CGFloat = 0
    private(set) var below = false
    private(set) var pointing = true
    private(set) var waiting = 0
    private(set) var shown = false
    private(set) var count = 0
    private(set) var background = Color.white
    private(set) var foreground = Color.black.opacity(0.85)
    private(set) var heading = Color.black
    private(set) var accent = Color.black
    private(set) var link: URL?
    private(set) var linkTitle = ""
    private(set) var forever = false
    private(set) var truncated = false
    private(set) var expanded = false
    private(set) var openness: CGFloat = 0
    private(set) var short = ""
    private(set) var full = ""
    private(set) var folded = CGSize.zero
    private(set) var unfolded = CGSize.zero
    private(set) var scroll: CGFloat?
    private(set) var inset = CGPoint.zero
    private(set) var lines = AppSettings.shared.bubbleLines
    private(set) var progress: Double = 0
    private(set) var fontSize = CGFloat(AppSettings.shared.bubbleFont)

    var font: NSFont { .monospacedSystemFont(ofSize: fontSize, weight: .semibold) }
    var linkFont: NSFont { .monospacedSystemFont(ofSize: max(9, fontSize - 2), weight: .semibold) }
    var titleFont: NSFont { .monospacedSystemFont(ofSize: fontSize + 1, weight: .heavy) }
    var hasHeader: Bool { title != nil || subtitle != nil }
    var scrolls: Bool { expanded && scroll != nil }
    var zoom: CGFloat { fontSize / Self.baseFont }
    var expandTitle: String { expanded ? Self.less : Self.more }
    var width: CGFloat { (folded.width + (unfolded.width - folded.width) * openness).rounded() }
    var textHeight: CGFloat { (folded.height + (unfolded.height - folded.height) * openness).rounded() }
    var shortCount: Int { expanded ? short.count : count }
    var fullCount: Int { expanded ? count : full.count }
    private static var more: String { tr("more", "więcej") }
    private static var less: String { tr("less", "mniej") }

    private enum Phase { case idle, typing, reading, erasing, hiding }

    @ObservationIgnored var offset: CGFloat?
    @ObservationIgnored var onShow: (() -> Void)?
    @ObservationIgnored var channel = Channel.mainID
    @ObservationIgnored private var started = false
    @ObservationIgnored private var parked: Date?
    @ObservationIgnored private var phase = Phase.idle
    @ObservationIgnored private var phaseStart = Date.now
    @ObservationIgnored private var readTime: TimeInterval = 4
    @ObservationIgnored private var paused: TimeInterval = 0
    @ObservationIgnored private var foldFrom: CGFloat = 0
    @ObservationIgnored private var foldStart = Date.now
    @ObservationIgnored private var maxWidth = CGFloat(AppSettings.shared.bubbleWidth)
    @ObservationIgnored private var expandedWidth = CGFloat(AppSettings.shared.expandedWidth)
    @ObservationIgnored private var expandedLines = AppSettings.shared.expandedLines
    @ObservationIgnored private var room = NSSize(width: 1200, height: 800)
    @ObservationIgnored private var window: NSPanel?
    @ObservationIgnored private var host: NSHostingController<BubbleCanvas>?
    @ObservationIgnored private var measurer: NSHostingController<BubbleView>?
    @ObservationIgnored private var measured = NSSize.zero
    @ObservationIgnored private var lastFit = NSSize.zero
    @ObservationIgnored private var chrome: NSSize?

    func say(_ message: String, title: String? = nil, subtitle: String? = nil, style: BubbleStyle = .bubble, for seconds: TimeInterval? = nil, link: URL? = nil, background: Color = .white, foreground: Color = .black.opacity(0.85), heading: Color = .black, accent: Color = .black) {
        self.heading = heading
        self.accent = accent
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.background = background
        self.foreground = foreground
        self.link = link
        linkTitle = link.map(Self.title) ?? ""
        full = message
        expanded = false
        openness = 0
        fit()
        let text = self.text ?? message
        count = 0
        shown = false
        phase = .idle
        readTime = seconds ?? min(8, max(2.5, 2 + Double(text.count) / 25))
        forever = readTime.isInfinite
        progress = 0
    }

    func resume() {
        if !started {
            started = true
            parked = nil
            phase = .typing
            phaseStart = .now.addingTimeInterval(0.18)
            reveal()
            onShow?()
            return
        }
        guard let parked else { return }
        self.parked = nil
        let pause = Date.now.timeIntervalSince(parked)
        phaseStart += pause
        foldStart += pause
        reveal()
    }

    func park() {
        guard parked == nil else { return }
        parked = .now
        shown = false
        offset = nil
        window?.orderOut(nil)
    }

    func owns(_ window: NSWindow?) -> Bool {
        window != nil && window === self.window
    }

    private func reveal() {
        Task {
            try? await Task.sleep(for: .milliseconds(40))
            if parked == nil { shown = true }
        }
    }

    var finished: Bool { text == nil }

    func update(_ now: Date) {
        guard let text else { return }
        fold(now)
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
            if expanded { break }
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

    func toggleExpanded() {
        guard truncated, phase == .typing || phase == .reading else { return }
        if phase == .typing {
            phase = .reading
            phaseStart = .now
        }
        if expanded {
            phaseStart = .now.addingTimeInterval(-paused)
        } else {
            paused = Date.now.timeIntervalSince(phaseStart)
        }
        expanded.toggle()
        foldFrom = openness
        foldStart = .now
        fit()
        count = text?.count ?? 0
    }

    private func fold(_ now: Date) {
        let goal: CGFloat = expanded ? 1 : 0
        guard openness != goal else { return }
        let p = min(1, now.timeIntervalSince(foldStart) / Self.foldTime)
        let eased = p < 0.5 ? 4 * p * p * p : 1 - pow(-2 * p + 2, 3) / 2
        openness = p >= 1 ? goal : foldFrom + (goal - foldFrom) * eased
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

    private func fit() {
        let lineHeight = height("X\nX", width: 1000) / 2
        truncated = height(full, width: maxWidth) > lineHeight * (CGFloat(lines) + 0.5)
        var short = full
        if truncated {
            let char = "M".size(withAttributes: [.font: font]).width
            let capacity = Int(maxWidth / char * CGFloat(lines) * 0.85)
            if short.count > capacity { short = String(short.prefix(capacity - 1)).trimmingCharacters(in: .whitespaces) + "…" }
        }
        if self.short != short { self.short = short }
        let text = expanded ? full : short
        if self.text != text { self.text = text }
        let linkWidth = link == nil ? 0 : (linkTitle as NSString).size(withAttributes: [.font: linkFont]).width
        let expandWidth = truncated ? [Self.more, Self.less].map { ($0 as NSString).size(withAttributes: [.font: linkFont]).width }.max()! + linkFont.pointSize + 4 : 0
        let footer = linkWidth + expandWidth + (link != nil && truncated ? 12 : 0)
        let header = hasHeader ? (title ?? "").size(withAttributes: [.font: titleFont]).width + (subtitle ?? "").size(withAttributes: [.font: linkFont]).width + 20 : 0
        let foldedWidth = min(maxWidth, ceil(max(widest(short), footer, header)) + 2)
        folded = CGSize(width: foldedWidth, height: truncated ? min(height(short, width: foldedWidth), ceil(lineHeight * CGFloat(lines))) : 0)
        guard truncated else {
            unfolded = folded
            if scroll != nil { scroll = nil }
            count = min(count, text.count)
            return
        }
        let wide = min(max(maxWidth, expandedWidth), room.width)
        let needed = ceil(max(widest(full), footer, header)) + 2
        let tall = height(full, width: min(wide, needed))
        let space = min(CGFloat(expandedLines) * lineHeight, room.height - (chrome?.height ?? lineHeight * 6))
        let limit = max(folded.height, floor(space / lineHeight) * lineHeight)
        let scroll: CGFloat? = tall > limit ? limit : nil
        if scroll != self.scroll { self.scroll = scroll }
        unfolded = CGSize(width: min(wide, needed), height: scroll ?? tall)
        count = min(count, text.count)
    }

    private func widest(_ string: String) -> CGFloat {
        string.split(separator: "\n", omittingEmptySubsequences: false).map { String($0).size(withAttributes: [.font: font]).width }.max() ?? 0
    }

    private func height(_ string: String, width: CGFloat) -> CGFloat {
        Self.sizer.rootView = AnyView(Text(string).font(Font(font)).fixedSize(horizontal: false, vertical: true).frame(width: width, alignment: .leading))
        return ceil(Self.sizer.sizeThatFits(in: NSSize(width: width, height: .greatestFiniteMagnitude)).height)
    }

    func layout(below: Bool, pointing: Bool, waiting: Int, room: NSSize) -> NSSize {
        let settings = AppSettings.shared
        let size = CGFloat(settings.bubbleFont)
        let maxWidth = CGFloat(settings.bubbleWidth)
        let expandedWidth = CGFloat(settings.expandedWidth)
        let moved = abs(room.width - self.room.width) > 24 || abs(room.height - self.room.height) > 24
        if moved { self.room = room }
        if size != fontSize || maxWidth != self.maxWidth || settings.bubbleLines != lines || expandedWidth != self.expandedWidth || settings.expandedLines != expandedLines || moved && expanded {
            fontSize = size
            self.maxWidth = maxWidth
            self.expandedWidth = expandedWidth
            lines = settings.bubbleLines
            expandedLines = settings.expandedLines
            fit()
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
            let host = NSHostingController(rootView: BubbleCanvas(bubble: self))
            host.sizingOptions = []
            panel.contentViewController = host
            let measurer = NSHostingController(rootView: BubbleView(bubble: self))
            measurer.sizingOptions = []
            window = panel
            self.host = host
            self.measurer = measurer
        }
        let fit = measurer?.sizeThatFits(in: NSSize(width: 4000, height: 4000)) ?? .zero
        if fit == lastFit, openness == (expanded ? 1 : 0) { chrome = NSSize(width: fit.width - width, height: fit.height - textHeight) }
        lastFit = fit
        let base = chrome ?? NSSize(width: fit.width - width, height: fit.height - textHeight)
        measured = NSSize(width: base.width + width, height: base.height + textHeight)
        return NSSize(width: ceil(measured.width), height: ceil(measured.height))
    }

    func move(to frame: NSRect, center: CGFloat, screen: NSRect) {
        guard let window else { return }
        let canvas = NSSize(
            width: max(frame.width, ceil(measured.width + max(folded.width, unfolded.width) - width - 0.01)),
            height: max(frame.height, ceil(measured.height + max(folded.height, unfolded.height) - textHeight - 0.01))
        )
        let anchor = switch style {
        case .bubble: center - canvas.width / 2
        case .left: frame.maxX - canvas.width
        case .right: frame.minX
        }
        let x = canvas.width > frame.width ? min(max(anchor, screen.minX + 4), screen.maxX - canvas.width - 4) : frame.minX
        let target = NSRect(x: x, y: below ? frame.maxY - canvas.height : frame.minY, width: canvas.width, height: canvas.height).integral
        let inset = CGPoint(x: (frame.minX - target.minX).rounded(), y: (target.maxY - frame.maxY).rounded())
        if inset != self.inset { self.inset = inset }
        let tail: CGFloat = switch style {
        case .bubble: (center - target.minX - inset.x).rounded()
        case .left: 24
        case .right: frame.width - 16
        }
        if tail != self.tail { self.tail = tail }
        if window.frame != target {
            if window.frame.size == target.size { window.setFrameOrigin(target.origin) } else { window.setFrame(target, display: true) }
        }
        let interactive = frame.contains(NSEvent.mouseLocation)
        if window.ignoresMouseEvents == interactive { window.ignoresMouseEvents = !interactive }
        if !window.isVisible { window.orderFrontRegardless() }
    }

    func close() {
        window?.orderOut(nil)
        window = nil
        host = nil
        measurer = nil
    }
}
