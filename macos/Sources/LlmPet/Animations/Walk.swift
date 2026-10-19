import Foundation

extension Pose {
    mutating func walk(walked: CGFloat) {
        let phase = Int(walked / 8) % 2
        legs = phase == 0 ? [0.45, 0, 0.45, 0] : [0, 0.45, 0, 0.45]
        bob = phase == 0 ? -0.15 : 0
        look = 0.5
    }
}
