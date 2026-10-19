import Foundation

extension Pose {
    mutating func idle(clock: TimeInterval) {
        look = [0, 0, -0.5, 0, 0.5, 0][Int(clock / 1.2) % 6]
    }
}
