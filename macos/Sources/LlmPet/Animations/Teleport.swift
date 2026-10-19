import SwiftUI

enum Teleport {
    static let duration = 2.8
    static let portalX: CGFloat = -95
    static let portalUp: CGFloat = 175
    static let radius = CGSize(width: 16, height: 46)
    static let start: CGFloat = portalX - 40
    static let height: CGFloat = portalUp - 31.5

    struct Portal {
        var ring: CGFloat
        var spark: CGFloat
        var opacity = 1.0
    }

    static func portal(_ t: TimeInterval) -> Portal? {
        let back = { (p: CGFloat) -> CGFloat in 1 + 2.7 * pow(p - 1, 3) + 1.7 * pow(p - 1, 2) }
        switch t {
        case ..<0.2: return Portal(ring: 0, spark: CGFloat(t / 0.2))
        case ..<0.5: return Portal(ring: back(CGFloat((t - 0.2) / 0.3)), spark: 1 - 0.5 * CGFloat((t - 0.2) / 0.3))
        case ..<0.95: return Portal(ring: 1, spark: 0.5)
        case ..<1.2:
            let q = CGFloat((t - 0.95) / 0.25)
            return Portal(ring: 1 - q * q, spark: 0.5 + 0.5 * q)
        case ..<1.4:
            let q = (t - 1.2) / 0.2
            return Portal(ring: 0, spark: 1 + 0.6 * CGFloat(q), opacity: 1 - q)
        default: return nil
        }
    }
}

extension Pose {
    mutating func teleport(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<0.55:
            hidden = true
        case ..<0.8:
            let p = CGFloat((t - 0.55) / 0.25)
            let shove = 1 - pow(1 - p, 3)
            dx = Teleport.start + (Teleport.portalX + 55 - Teleport.start) * shove
            lift = Teleport.height + 6 * sin(.pi * p)
            mask = Teleport.portalX
            tilt = -6
            tiltAnchor = .center
            eyes = .wide
            left = .flail
            right = .flail
            legLength = 1.5
        case ..<1.15:
            let p = CGFloat((t - 0.8) / 0.35)
            dx = Teleport.portalX + 55 + 45 * (1 - (1 - p) * (1 - p))
            lift = Teleport.height * (1 - p * p)
            tilt = Double(-6 + 26 * p * p)
            tiltAnchor = .center
            eyes = .wide
            left = .flail
            right = .flail
            legLength = 1.5
        case ..<1.3:
            let k = sin(.pi * (t - 1.15) / 0.15)
            dx = 5
            sx = 1 + 0.3 * k
            sy = 1 - 0.32 * k
            eyes = .closed
            dust = CGFloat((t - 1.15) / 0.45)
        case ..<1.55:
            let q = (t - 1.3) / 0.25
            dx = 5
            lift = 12 * CGFloat(sin(.pi * q))
            sy = 1 + 0.06 * CGFloat(sin(.pi * q))
            eyes = .dizzy
            dust = CGFloat((t - 1.15) / 0.45)
        case ..<2.3:
            dx = 5
            eyes = .dizzy
            stars = true
            tilt = 6 * sin(clock * 9)
            sx = 1 + 0.03 * CGFloat(sin(clock * 9))
        case ..<2.55:
            dx = 5
            look = Int((t - 2.3) / 0.06) % 2 == 0 ? -0.5 : 0.5
            sx = 1.04
            sy = 0.97
        default:
            dx = 5 * CGFloat(1 - (t - 2.55) / 0.25)
            eyes = .happy
        }
    }
}
