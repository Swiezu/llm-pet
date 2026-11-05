import AppKit
import SwiftUI

@MainActor
final class BubbleStack {
    static let visible = 2
    static let maxQueue = 20
    private static let overlap: CGFloat = 10
    private static let indent: CGFloat = 16

    private struct Message {
        let text: String
        let title: String?
        let subtitle: String?
        let style: BubbleStyle
        let seconds: TimeInterval?
        let link: URL?
        let background: Color
        let foreground: Color
        let heading: Color
        let accent: Color
        let onShow: (() -> Void)?
    }

    private(set) var active: [Bubble] = []
    private var queue: [Message] = []
    private var lastPlace = Date.now

    var speaking: Bool { !active.isEmpty }
    var queued: Int { queue.count }

    func say(_ text: String, title: String? = nil, subtitle: String? = nil, style: BubbleStyle = .bubble, for seconds: TimeInterval?, link: URL?, background: Color, foreground: Color, heading: Color, accent: Color, onShow: (() -> Void)? = nil) -> Int? {
        let message = Message(text: text, title: title, subtitle: subtitle, style: style, seconds: seconds, link: link, background: background, foreground: foreground, heading: heading, accent: accent, onShow: onShow)
        if active.count < Self.visible, queue.isEmpty {
            show(message)
            return 0
        }
        guard queue.count < Self.maxQueue else { return nil }
        queue.append(message)
        return queue.count
    }

    func update(_ now: Date) {
        for bubble in active { bubble.update(now) }
        for bubble in active where bubble.finished { bubble.close() }
        active.removeAll(where: \.finished)
        while active.count < Self.visible, !queue.isEmpty { show(queue.removeFirst()) }
    }

    func place(on screen: NSRect, center: CGFloat, bottom: CGFloat, head: CGFloat) {
        let now = Date.now
        let step = min(1, now.timeIntervalSince(lastPlace) * 14)
        lastPlace = now
        guard !active.isEmpty else { return }
        let above = screen.maxY - head
        let under = bottom + 10 - screen.minY
        let room = NSSize(width: screen.width - 40, height: max(above, under) - 4)
        let stacked = active.reduce(CGFloat(0)) { $0 + $1.layout(below: $1.below, pointing: $1 === active.first || $1.style != .bubble, waiting: $1.waiting, room: room).height + gap($1) }
        let below = stacked > above && under > above
        var offset: CGFloat = 0
        for (index, bubble) in active.enumerated() {
            let size = bubble.layout(below: below, pointing: index == 0 || bubble.style != .bubble, waiting: index == active.count - 1 ? queue.count : 0, room: room)
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

    private func gap(_ bubble: Bubble) -> CGFloat {
        bubble.style == .bubble ? -Self.overlap : 4
    }

    func close() {
        for bubble in active { bubble.close() }
        active.removeAll()
        queue.removeAll()
    }

    private func show(_ message: Message) {
        let bubble = Bubble()
        bubble.say(message.text, title: message.title, subtitle: message.subtitle, style: message.style, for: message.seconds, link: message.link, background: message.background, foreground: message.foreground, heading: message.heading, accent: message.accent)
        active.append(bubble)
        message.onShow?()
    }
}
