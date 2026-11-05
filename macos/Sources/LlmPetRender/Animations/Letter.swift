import SwiftUI

enum Mail {
    static let duration = 6.4
    static let catchTime = 1.45
    static let hand = CGPoint(x: 25, y: 66)
}

extension Pose {
    mutating func letter(t: TimeInterval, clock: TimeInterval) {
        if t < Mail.catchTime {
            let p = CGFloat(t / Mail.catchTime)
            let glide = p * p * (3 - 2 * p)
            flying = Flying(
                kind: .envelope,
                x: 190 + (Mail.hand.x - 190) * glide + 10 * CGFloat(sin(t * 7)) * (1 - p),
                up: 250 + (Mail.hand.y - 250) * glide + 12 * CGFloat(sin(t * 9)) * (1 - p),
                frame: Int(t / 0.12) % 2
            )
        }
        switch t {
        case ..<0.5:
            break
        case ..<0.9:
            exclaim = true
            eyes = .wide
            look = 0.5
            lookY = -0.4
        case ..<1.25:
            look = 0.5
            lookY = -0.4
            sy = 1 - 0.06 * CGFloat(sin(.pi * (t - 0.9) / 0.35))
        case ..<1.65:
            let q = (t - 1.25) / 0.4
            right = .up
            look = 0.4
            lookY = -0.4
            lift = 14 * CGFloat(sin(.pi * q))
            if t >= Mail.catchTime { letter = .raised }
        case ..<2.2:
            left = .reach(0.3)
            right = .reach(0.3)
            letter = .envelope
            eyes = .happy
        case ..<2.7:
            left = .reach(0.3)
            right = .reach(0.3)
            letter = .opening(CGFloat((t - 2.2) / 0.5))
            lookY = 0.15
        case ..<5.2:
            left = .reach(0.4)
            right = .reach(0.4)
            letter = .reading
            look = [-0.4, -0.1, 0.2, 0.4][Int((t - 2.7) / 0.25) % 4]
            lookY = 0.12
            bob = Int((t - 2.7) / 1.0) % 2 == 0 ? 0 : 0.08
        case ..<5.6:
            left = .reach(0.4)
            right = .reach(0.4)
            letter = .reading
            eyes = .happy
            heart = CGFloat((t - 5.2) / 0.8)
        default:
            eyes = .happy
            heart = t < 6.0 ? CGFloat((t - 5.2) / 0.8) : nil
            right = Int((t - 5.6) / 0.2) % 2 == 0 ? .up : .diagUp
        }
    }
}
