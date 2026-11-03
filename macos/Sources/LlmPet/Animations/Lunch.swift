import SwiftUI

enum Lunch {
    static let duration = 8.6
}

extension Pose {
    mutating func lunch(t: TimeInterval, clock: TimeInterval) {
        let lap = point(6.4, 4.9)
        let mouth = point(7.4, 4.3)
        func lerp(_ a: CGPoint, _ b: CGPoint, _ p: CGFloat) -> CGPoint {
            let e = Pose.ease(p)
            return CGPoint(x: a.x + (b.x - a.x) * e, y: a.y + (b.y - a.y) * e)
        }
        func crumbs(_ p: CGFloat) {
            for crumb in 0..<4 {
                let q = min(1, p * 1.3 - CGFloat(crumb) * 0.08)
                guard q > 0 else { continue }
                dot(crumb % 2 == 0 ? "b" : "y", mouth.x + 6 + CGFloat(crumb * 4 - 6) + 8 * q, mouth.y - 4 - 20 * q * q, opacity: Double(1 - q * 0.6))
            }
        }
        switch t {
        case ..<0.7:
            let shake: CGFloat = Int(clock / 0.06) % 2 == 0 ? 0.03 : -0.03
            eyes = .wide
            lookY = 0.4
            sx = 1 + shake
            exclaim = t > 0.2
            place(Art.growl, at: point(1.0, 4.6), opacity: Double(sin(.pi * t / 0.7)))
            place(Art.growl, at: point(11.0, 4.2), opacity: Double(sin(.pi * t / 0.7)))
        case ..<1.1:
            let p = CGFloat((t - 0.7) / 0.4)
            right = .diagDown
            left = .reach(0.3)
            eyes = .open
            look = 0.3
            lookY = 0.3
            place(Art.burger[0], at: lap, scale: 1.4 * (0.4 + 0.6 * Pose.ease(p * 1.5)))
        case ..<1.6:
            left = .reach(0.3)
            right = .reach(0.3)
            eyes = .happy
            lookY = 0.4
            heart = CGFloat((t - 1.1) / 0.5)
            place(Art.burger[0], at: lap, scale: 1.4)
        case ..<5.2:
            let local = (t - 1.6).truncatingRemainder(dividingBy: 0.9)
            let bite = min(3, Int((t - 1.6) / 0.9))
            let before = Art.burger[bite]
            let after = Art.burger[min(bite + 1, 3)]
            left = .reach(0.3)
            right = .reach(0.3)
            if local < 0.2 {
                let p = CGFloat(local / 0.2)
                left = .reach(0.3 + 0.6 * Pose.ease(p))
                right = .reach(0.3 + 0.6 * Pose.ease(p))
                eyes = .open
                place(before, at: lerp(lap, mouth, p), scale: 1.4)
            } else if local < 0.35 {
                left = .reach(0.9)
                right = .reach(0.9)
                eyes = .closed
                sy = 0.94
                sx = 1.04
                place(bite == 3 ? after : before, at: mouth, scale: 1.4)
            } else {
                let p = CGFloat((local - 0.35) / 0.55)
                let chew = Int(local / 0.11) % 2 == 0
                left = .reach(0.9 - 0.6 * Pose.ease(min(1, p * 2)))
                right = .reach(0.9 - 0.6 * Pose.ease(min(1, p * 2)))
                eyes = .happy
                sx = chew ? 1.05 : 1.01
                bob = chew ? 0.1 : 0
                if bite < 3 { place(after, at: lerp(mouth, lap, min(1, p * 2)), scale: 1.4) }
                crumbs(p)
            }
        case ..<5.9:
            let tap = Int((t - 5.2) / 0.14) % 2 == 0
            left = .reach(tap ? 0 : 0.25)
            right = .reach(tap ? 0.25 : 0)
            eyes = .happy
            sx = 1.06
            sy = 0.97
        case ..<6.9:
            let p = CGFloat((t - 5.9) / 1.0)
            right = .reach(p < 0.2 ? 0.3 : 0.9)
            eyes = p < 0.2 ? .open : .closed
            sx = 1.06
            place(Art.soda, at: p < 0.2 ? point(11.8, 3.9) : lerp(point(11.8, 3.9), point(9.6, 3.5), (p - 0.2) * 4), scale: 1.4)
        case ..<7.6:
            let p = CGFloat((t - 6.9) / 0.7)
            eyes = .closed
            sy = 1 + 0.07 * sin(.pi * p)
            sx = 1.06
            if p > 0.3 { place(Art.puffBig, mouth.x + 12 + 12 * p, mouth.y + 6 + 16 * p, opacity: Double(1 - p * p), scale: 0.5 + 0.7 * p) }
        default:
            let p = CGFloat((t - 7.6) / 1.0)
            eyes = .happy
            sx = 1.06
            sy = 0.98
            heart = p
            left = .reach(0.1)
            right = .reach(0.1)
        }
    }
}
