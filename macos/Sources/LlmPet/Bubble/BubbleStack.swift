import AppKit
import SwiftUI

@MainActor
final class BubbleStack {
    static let visible = 2
    static let maxQueue = 20
    private static let overlap: CGFloat = 10

    private struct Message {
        let text: String
        let seconds: TimeInterval?
        let link: URL?
        let background: Color
        let foreground: Color
        let onShow: (() -> Void)?
    }

    private(set) var active: [Bubble] = []
    private var queue: [Message] = []
    private var lastPlace = Date.now

    var speaking: Bool { !active.isEmpty }
    var queued: Int { queue.count }

    func say(_ text: String, for seconds: TimeInterval?, link: URL?, background: Color, foreground: Color, onShow: (() -> Void)? = nil) -> Int? {
        let message = Message(text: text, seconds: seconds, link: link, background: background, foreground: foreground, onShow: onShow)
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
        let stacked = active.reduce(CGFloat(0)) { $0 + $1.layout(below: $1.below, pointing: $1 === active.first, waiting: $1.waiting).height - Self.overlap }
        let below = head + stacked > screen.maxY
        var offset: CGFloat = 0
        for (index, bubble) in active.enumerated() {
            let size = bubble.layout(below: below, pointing: index == 0, waiting: index == active.count - 1 ? queue.count : 0)
            let current = bubble.offset.map { $0 + (offset - $0) * step } ?? offset
            bubble.offset = current
            let x = min(max(center - size.width / 2, screen.minX + 4), screen.maxX - size.width - 4)
            let y = below ? max(screen.minY, bottom - size.height + 10 - current) : head + current
            bubble.move(to: NSRect(x: x, y: y, width: size.width, height: size.height), tail: center - x)
            offset += size.height - Self.overlap
        }
    }

    func close() {
        for bubble in active { bubble.close() }
        active.removeAll()
        queue.removeAll()
    }

    private func show(_ message: Message) {
        let bubble = Bubble()
        bubble.say(message.text, for: message.seconds, link: message.link, background: message.background, foreground: message.foreground)
        active.append(bubble)
        message.onShow?()
    }
}
