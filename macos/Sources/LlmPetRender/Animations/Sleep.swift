import Foundation

extension Pose {
    mutating func sleep(clock: TimeInterval) {
        let breath = sin(2 * .pi * clock / 4)
        eyes = .closed
        sy = 0.94 + 0.04 * breath
        sx = 1.04 - 0.02 * breath
    }
}
