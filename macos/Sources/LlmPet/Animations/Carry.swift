import SwiftUI

extension Pose {
    mutating func carry(held: Bool, clock: TimeInterval) {
        carried = true
        left = .flail
        right = .flail
        eyes = .open
        if held {
            tilt = 8 * sin(clock * 7)
            tiltAnchor = UnitPoint(x: 0.5, y: Style.origin.y / Style.canvas.height)
            sy = 1.07
            sx = 0.95
        } else {
            sy = 1.1
            sx = 0.92
        }
    }

    mutating func land(_ elapsed: TimeInterval) {
        let k = sin(.pi * elapsed / 0.3)
        sx = 1 + 0.08 * k
        sy = 1 - 0.1 * k
    }
}
