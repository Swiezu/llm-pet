import Foundation

package enum Idle {
    static let look = 1.2
    static let blink = (every: 3.6, length: 0.12)

    package static func change(after clock: TimeInterval) -> TimeInterval {
        [(look, 0.0), (blink.every, 0.0), (blink.every, blink.length)].map { step, offset in
            offset + (((clock - offset) / step).rounded(.down) + 1) * step + 0.001
        }.min()!
    }
}

extension Pose {
    mutating func idle(clock: TimeInterval) {
        look = [0, 0, -0.5, 0, 0.5, 0][Int(clock / Idle.look) % 6]
    }
}
