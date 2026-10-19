import Foundation

extension Pose {
    mutating func flag(t: TimeInterval) {
        eyes = .happy
        narrow = true
        right = .up
        flag = true
        let step = Int(t / 0.18) % 4
        legs = [[0.3, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0.3, 0], [0, 0, 0, 0]][step]
        bob = step % 2 == 0 ? -0.1 : 0
    }
}
