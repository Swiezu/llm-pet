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
    private(set) var scale = CGFloat(AppSettings.shared.petScale)
    @ObservationIgnored private(set) var resizeUntil = Date.distantPast
    @ObservationIgnored private(set) var growing = true

    @ObservationIgnored let bubbles = BubbleStack()
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
    @ObservationIgnored private var scaleSpeed: CGFloat = 0

    var frameSize: CGSize { CGSize(width: Self.size.width * scale, height: Self.size.height * scale) }

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
    func say(_ message: String, for seconds: TimeInterval? = nil, link: URL? = nil, animation: Action? = nil, on channel: Channel = AppSettings.shared.main) -> Int? {
        guard enabled, !channel.muted else { return nil }
        return bubbles.say(message, for: seconds, link: link, background: channel.background, foreground: channel.foreground, onShow: animation.map { action in { [weak self] in self?.perform(action) } })
    }

    func perform(_ next: Action) {
        guard enabled, !held, !falling else { return }
        if next == .walk, let screen = (window?.screen ?? NSScreen.main)?.visibleFrame {
            target = .random(in: (screen.minX - Self.edge * scale)...(screen.maxX - frameSize.width + Self.edge * scale))
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
        rest = (y ?? 0) - Self.drop * scale
        start(.idle)
    }

    private func show() {
        guard window == nil else { return }
        scale = CGFloat(AppSettings.shared.petScale)
        scaleSpeed = 0
        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: frameSize), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
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
        bubbles.close()
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
        resize(now, dt: k / 60)
        bubbles.update(now)
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
        let size = frameSize
        x = min(max(x, screen.minX - Self.edge * scale), screen.maxX - size.width + Self.edge * scale)
        y = min(max(y ?? floor, floor), screen.maxY - size.height)
        let frame = NSRect(x: x.rounded(), y: (y ?? floor).rounded(), width: size.width.rounded(), height: size.height.rounded())
        if let window, window.frame != frame { window.setFrame(frame, display: true) }
    }

    private func resize(_ now: Date, dt: CGFloat) {
        let target = CGFloat(AppSettings.shared.petScale)
        guard scale != target || scaleSpeed != 0 else { return }
        if abs(target - scale) > 0.01 {
            growing = target > scale
            resizeUntil = now.addingTimeInterval(0.45)
        }
        var next = scale
        let steps = max(1, Int((dt * 240).rounded(.up)))
        let step = dt / CGFloat(steps)
        for _ in 0..<steps {
            scaleSpeed += ((target - next) * 170 - scaleSpeed * 11) * step
            next += scaleSpeed * step
        }
        if abs(target - next) < 0.002, abs(scaleSpeed) < 0.02 {
            next = target
            scaleSpeed = 0
        }
        x -= Self.size.width * (next - scale) / 2
        scale = next
    }

    private func placeBubble(_ screen: NSRect, floor: CGFloat, now: Date) {
        let bottom = y ?? floor
        let lift = action == .hop && !held && !falling ? Hop.lift(now.timeIntervalSince(actionStart)) : 0
        bubbles.place(on: screen, center: x + frameSize.width / 2, bottom: bottom, head: bottom + (58 + lift) * scale)
    }
}
