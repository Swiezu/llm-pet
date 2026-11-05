import SwiftUI

enum Buffering {
    static let duration = 6.4
}

extension Pose {
    private mutating func spinner(_ clock: TimeInterval, done: Bool) {
        let center = point(6, -3.4)
        let head = Int(clock / 0.1) % 8
        for index in 0..<8 {
            let angle = Double(index) / 8 * 2 * .pi - .pi / 2
            let age = (head - index + 8) % 8
            let opacity = done ? 1 : max(0.15, 1 - Double(age) * 0.18)
            dot(done ? "e" : "x", center.x + 14 * CGFloat(cos(angle)), center.y - 14 * CGFloat(sin(angle)), size: 2, opacity: opacity)
        }
    }

    mutating func buffering(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<0.7:
            let step = Int(t / 0.17) % 2
            legs = step == 0 ? [0.45, 0, 0.45, 0] : [0, 0.45, 0, 0.45]
            bob = step == 0 ? -0.15 : 0
            look = 0.5
        case ..<4.8:
            legs = [0.45, 0, 0.45, 0]
            bob = -0.15
            look = 0.5
            tilt = 3
            eyes = .open
            let spike = (t - 0.7).truncatingRemainder(dividingBy: 0.6) < 0.08
            if spike {
                dx = Int(clock / 0.02) % 2 == 0 ? 4 : -4
                sx = 1.06
                eyes = .closed
                legs = [0, 0.45, 0, 0.45]
            }
            if t > 0.85 { spinner(clock, done: false) }
            if t > 2.2 { thought = 0 }
        case ..<5.1:
            legs = [0.45, 0, 0.45, 0]
            bob = -0.15
            tilt = 3
            look = 0.5
            spinner(clock, done: true)
        default:
            let step = Int(t / 0.07) % 2
            legs = step == 0 ? [0.5, 0, 0.5, 0] : [0, 0.5, 0, 0.5]
            bob = step == 0 ? -0.2 : 0
            lift = t < 5.6 ? 6 * abs(CGFloat(sin((t - 5.1) * 14))) : 0
            eyes = t > 5.7 ? .happy : .open
            look = 0.5
        }
    }
}
