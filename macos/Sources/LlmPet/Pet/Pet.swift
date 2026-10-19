import AppKit
import Observation
import SwiftUI

@MainActor
@Observable
final class Pet {
    static let shared = Pet()
    static let size = CGSize(width: 360, height: 320)
    static let drop: CGFloat = 8
    static let edge = (size.width - Style.canvas.width * Style.unit) / 2 - 7

    private(set) var enabled = UserDefaults.standard.object(forKey: "petEnabled") as? Bool ?? true
    private(set) var action = Action.idle
    private(set) var actionStart = Date.now
    private(set) var facing: CGFloat = 1
    @ObservationIgnored private(set) var walked: CGFloat = 0
    private(set) var held = false
    private(set) var falling = false
    private(set) var landStart: Date?

    @ObservationIgnored let bubble = Bubble()
    @ObservationIgnored private var window: NSPanel?
    @ObservationIgnored private var loop: Task<Void, Never>?
    @ObservationIgnored private var x: CGFloat = 170
    @ObservationIgnored private var y: CGFloat?
    @ObservationIgnored private var target: CGFloat = 240
    @ObservationIgnored private var speed: CGFloat = 0
    @ObservationIgnored private var fall: CGFloat = 0
    @ObservationIgnored private var rest: CGFloat = 0
    @ObservationIgnored private var grab = CGPoint.zero
    @ObservationIgnored private var until = Date.distantFuture
    @ObservationIgnored private var lastTick = Date.now

    func restore() {
        if enabled { show() }
    }

    func toggle() {
        setEnabled(!enabled)
    }

    func setEnabled(_ value: Bool) {
        enabled = value
        UserDefaults.standard.set(enabled, forKey: "petEnabled")
        enabled ? show() : hide()
    }

    @discardableResult
    func say(_ message: String, for seconds: TimeInterval? = nil, on channel: Channel = AppSettings.shared.main) -> Bool {
        guard enabled, !channel.muted else { return false }
        bubble.say(message, for: seconds, background: channel.background, foreground: channel.foreground)
        return true
    }

    func perform(_ next: Action) {
        guard enabled, !held, !falling else { return }
        if next == .walk, let screen = (window?.screen ?? NSScreen.main)?.visibleFrame {
            target = .random(in: (screen.minX - Self.edge)...(screen.maxX - Self.size.width + Self.edge))
        }
        if next == .teleport { facing = 1 }
        start(next)
    }

    func poke() {
        start(Action.tricks.randomElement() ?? .hop)
    }

    func hold() {
        let mouse = NSEvent.mouseLocation
        if !held {
            held = true
            falling = false
            grab = CGPoint(x: mouse.x - x, y: mouse.y - (y ?? 0))
        }
        let next = mouse.x - grab.x
        if abs(next - x) > 0.5 { facing = next > x ? 1 : -1 }
        x = next
        y = mouse.y - grab.y
    }

    func release() {
        held = false
        falling = true
        fall = 0
        rest = (y ?? 0) - Self.drop
        start(.idle)
    }

    private func show() {
        guard window == nil else { return }
        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: Self.size), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.contentView = NSHostingView(rootView: PetView(pet: self))
        panel.orderFrontRegardless()
        window = panel
        lastTick = .now
        perform(.teleport)
        loop = Task { [weak self] in
            while let self, !Task.isCancelled {
                tick()
                try? await Task.sleep(for: .seconds(1.0 / Double(AppSettings.shared.fps)))
            }
        }
    }

    private func hide() {
        loop?.cancel()
        loop = nil
        window?.orderOut(nil)
        window = nil
        bubble.close()
    }

    private func start(_ next: Action) {
        action = next
        actionStart = .now
        until = .now.addingTimeInterval(min(next.duration, 1e9))
    }

    private func finish() {
        let ended = action
        start(.idle)
        if ended == .teleport { say(DebugTexts.greeting(AppSettings.shared.lang)) }
    }

    private func tick() {
        guard let screen = (window?.screen ?? NSScreen.main)?.visibleFrame else { return }
        let now = Date.now
        let k = CGFloat(min(0.1, max(0, now.timeIntervalSince(lastTick))) * 60)
        lastTick = now
        let floor = screen.minY
        bubble.update(now)
        defer { placeBubble(screen, floor: floor, now: now) }
        if held {
            place(screen, floor: floor)
            return
        }
        if falling {
            let rest = max(floor, rest)
            fall += 0.12 * k
            y = max(rest, (y ?? floor) - fall * k)
            if y == rest {
                falling = false
                landStart = now
            }
            place(screen, floor: floor)
            return
        }
        if now >= until { finish() }
        if action == .walk {
            let distance = abs(target - x)
            speed = min(1.8, speed + 0.05 * k, max(0.35, distance / 30))
            if distance <= speed * k {
                x = target
                speed = 0
                start(.idle)
            } else {
                facing = target > x ? 1 : -1
                x += speed * facing * k
                walked += speed * k
            }
        }
        place(screen, floor: floor)
    }

    private func place(_ screen: NSRect, floor: CGFloat) {
        x = min(max(x, screen.minX - Self.edge), screen.maxX - Self.size.width + Self.edge)
        y = min(max(y ?? floor, floor), screen.maxY - Self.size.height)
        let origin = NSPoint(x: x.rounded(), y: (y ?? floor).rounded())
        if let window, window.frame.origin != origin { window.setFrameOrigin(origin) }
    }

    private func placeBubble(_ screen: NSRect, floor: CGFloat, now: Date) {
        let bottom = y ?? floor
        let lift = action == .hop && !held && !falling ? Hop.lift(now.timeIntervalSince(actionStart)) : 0
        bubble.place(on: screen, center: x + Self.size.width / 2, bottom: bottom, head: bottom + 58 + lift)
    }
}
