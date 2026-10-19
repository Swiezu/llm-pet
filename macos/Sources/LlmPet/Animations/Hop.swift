import Foundation

enum Hop {
    static let duration = 0.9

    static func lift(_ t: TimeInterval) -> CGFloat {
        let p = (t / duration).truncatingRemainder(dividingBy: 1)
        guard p >= 0.15, p < 0.88 else { return 0 }
        return 95 * sin(.pi * (p - 0.15) / 0.73)
    }
}

extension Pose {
    mutating func hop(t: TimeInterval) {
        let p = (t / Hop.duration).truncatingRemainder(dividingBy: 1)
        let hop = Int(t / Hop.duration)
        if p < 0.15 {
            let k = sin(.pi * p / 0.15)
            sx = 1 + 0.12 * k
            sy = 1 - 0.14 * k
        } else if p < 0.88 {
            let air = (p - 0.15) / 0.73
            lift = Hop.lift(t)
            tilt = (hop % 2 == 0 ? -8 : 8) * sin(.pi * air)
            tiltAnchor = .center
            legLength = 1.5
        } else {
            let k = sin(.pi * (p - 0.88) / 0.12)
            sx = 1 + 0.1 * k
            sy = 1 - 0.12 * k
        }
    }
}
