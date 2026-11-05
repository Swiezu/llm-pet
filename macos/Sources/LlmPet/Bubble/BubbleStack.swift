import AppKit
import SwiftUI

@MainActor
final class BubbleStack {
    static let maxQueue = 20
    private static let overlap: CGFloat = 10
    private static let indent: CGFloat = 16
    private static let scrollStep: CGFloat = 40

    private(set) var active: [Bubble] = []
    private var items: [Bubble] = []
    private var start = 0
    private var below = false
    private var scrolled: CGFloat = 0
    private var lastPlace = Date.now
    private var monitor: Any?

    var speaking: Bool { !items.isEmpty }
    var queued: Int { items.count - active.count }

    private var ordered: [Bubble] { AppSettings.shared.newestFirst ? items.reversed() : items }
    private var limit: Int { AppSettings.shared.bubbleCount == 0 ? .max : AppSettings.shared.bubbleCount }

    init() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
            MainActor.assumeIsolated { self?.scroll(event) == true } ? nil : event
        }
    }

    func say(_ text: String, title: String? = nil, subtitle: String? = nil, style: BubbleStyle = .bubble, for seconds: TimeInterval?, link: URL?, background: Color, foreground: Color, heading: Color, accent: Color, onShow: (() -> Void)? = nil) -> Int? {
        guard queued < Self.maxQueue else { return nil }
        let bubble = Bubble()
        bubble.say(text, title: title, subtitle: subtitle, style: style, for: seconds, link: link, background: background, foreground: foreground, heading: heading, accent: accent)
        bubble.onShow = onShow
        items.append(bubble)
        if AppSettings.shared.newestFirst {
            start = 0
            return 0
        }
        return max(0, items.count - start - min(limit, active.count + 1))
    }

    func update(_ now: Date) {
        for bubble in active { bubble.update(now) }
        for bubble in active where bubble.finished { bubble.close() }
        items.removeAll(where: \.finished)
        active.removeAll(where: \.finished)
    }

    func place(on screen: NSRect, center: CGFloat, bottom: CGFloat, head: CGFloat) {
        let now = Date.now
        let step = min(1, now.timeIntervalSince(lastPlace) * 14)
        lastPlace = now
        guard !items.isEmpty else {
            start = 0
            return
        }
        let list = ordered
        let above = screen.maxY - head
        let under = bottom + 10 - screen.minY
        let room = NSSize(width: screen.width - 40, height: max(above, under) - 4)
        start = min(start, list.count - 1)
        let up = fill(list, from: start, space: above, room: room)
        below = up.extent > above && under > above
        let space = below ? under : above
        var shown = below ? fill(list, from: start, space: under, room: room) : up
        while start > 0, start + shown.count == list.count, shown.count < limit {
            let back = fill(list, from: start - 1, space: space, room: room)
            guard back.count > shown.count else { break }
            start -= 1
            shown = back
        }
        let visible = Array(list[start..<(start + shown.count)])
        for bubble in items where !visible.contains(where: { $0 === bubble }) { bubble.park() }
        for bubble in visible { bubble.resume() }
        active = visible
        var offset: CGFloat = 0
        for (index, bubble) in visible.enumerated() {
            let size = bubble.layout(below: below, pointing: index == 0 || bubble.style != .bubble, waiting: index == visible.count - 1 ? list.count - visible.count : 0, room: room)
            let current = bubble.offset.map { $0 + (offset - $0) * step } ?? offset
            bubble.offset = current
            let shift = switch bubble.style {
            case .bubble: CGFloat(0)
            case .left: -Self.indent
            case .right: Self.indent
            }
            let margin = 4 + abs(shift)
            let x = min(max(center - size.width / 2, screen.minX + margin), screen.maxX - size.width - margin) + shift
            let y = below ? max(screen.minY, bottom - size.height + 10 - current) : head + current
            bubble.move(to: NSRect(x: x, y: y, width: size.width, height: size.height), center: center, screen: screen)
            offset += size.height + gap(bubble)
        }
    }

    private func fill(_ list: [Bubble], from first: Int, space: CGFloat, room: NSSize) -> (count: Int, extent: CGFloat) {
        var count = 0
        var offset: CGFloat = 0
        var extent: CGFloat = 0
        for bubble in list[first...] {
            guard count < limit else { break }
            let height = bubble.layout(below: bubble.below, pointing: count == 0 || bubble.style != .bubble, waiting: bubble.waiting, room: room).height
            if count > 0, offset + height > space { break }
            extent = offset + height
            offset += height + gap(bubble)
            count += 1
        }
        return (count, extent)
    }

    private func scroll(_ event: NSEvent) -> Bool {
        guard queued > 0, let bubble = active.first(where: { $0.owns(event.window) }), !bubble.scrolls else { return false }
        if event.phase == .began { scrolled = 0 }
        let delta = event.hasPreciseScrollingDeltas ? event.scrollingDeltaY : event.scrollingDeltaY * Self.scrollStep
        scrolled += below ? -delta : delta
        let steps = Int(scrolled / Self.scrollStep)
        guard steps != 0 else { return true }
        scrolled -= CGFloat(steps) * Self.scrollStep
        start = min(max(0, start + steps), items.count - active.count)
        return true
    }

    private func gap(_ bubble: Bubble) -> CGFloat {
        bubble.style == .bubble ? -Self.overlap : 4
    }

    func close() {
        for bubble in items { bubble.close() }
        items.removeAll()
        active.removeAll()
        start = 0
    }
}
