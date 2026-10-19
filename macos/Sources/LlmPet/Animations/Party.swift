import Foundation

extension Pose {
    mutating func party(t: TimeInterval) {
        let beat = Int(t / 0.42)
        if beat % 2 == 0 {
            sy = 0.82
            sx = 1.08
            legLength = 0.9
        } else {
            narrow = true
            flip = beat % 4 == 3
            right = .up
            sy = 1.06
            legLength = 1.45
        }
    }
}
