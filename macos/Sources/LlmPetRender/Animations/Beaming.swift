import SwiftUI

enum Beaming {
    static let upDuration = 2.2
    static let downDuration = 2.5
    static let width: CGFloat = 46
    static let sky: CGFloat = 340

    static func pillar(_ t: TimeInterval, motes: CGFloat) -> Pose.Pillar? {
        switch t {
        case ..<0.3:
            let p = Pose.ease(CGFloat(t / 0.3))
            return Pose.Pillar(width: 3, bottom: sky * (1 - p))
        case ..<0.55:
            let q = CGFloat((t - 0.3) / 0.25)
            return Pose.Pillar(width: 3 + (width - 3) * Teleport.back(q), ring: sin(.pi * q), motes: motes * q)
        case ..<1.35:
            return Pose.Pillar(width: width + 2 * CGFloat(sin(t * 40)), ring: 0.35, motes: motes)
        case ..<1.6:
            let q = CGFloat((t - 1.35) / 0.25)
            return Pose.Pillar(width: 3 + (width - 3) * (1 - q * q), ring: 0.35 * (1 - q), motes: motes * (1 - q))
        case ..<1.85:
            let q = CGFloat((t - 1.6) / 0.25)
            return Pose.Pillar(width: 3, bottom: sky * q * q)
        default: return nil
        }
    }
}

extension Pose {
    mutating func beamUp(t: TimeInterval, clock: TimeInterval) {
        pillar = Beaming.pillar(t, motes: 1)
        switch t {
        case ..<0.3:
            lookY = -0.5
            eyes = .wide
            exclaim = t > 0.12
        case ..<0.55:
            let q = CGFloat((t - 0.3) / 0.25)
            lookY = -0.5
            eyes = .happy
            left = .up
            right = .up
            sy = 1 - 0.08 * sin(.pi * q)
        case ..<1.35:
            let p = CGFloat((t - 0.55) / 0.8)
            let e = Pose.ease(p)
            eyes = .closed
            left = .up
            right = .up
            lift = 16 * e
            sx = 1 - 0.22 * e
            sy = 1 + 0.3 * e
            legLength = 1.2 + 0.3 * e
            glow = Double(0.85 * min(1, p * 1.6))
            dissolve = p
        default:
            hidden = true
            if t >= 1.85 { place(Art.sparkle[Int(clock / 0.1) % 2], 0, 290, opacity: max(0, 1 - (t - 1.85) / 0.35)) }
        }
    }

    mutating func beamDown(t: TimeInterval, clock: TimeInterval) {
        pillar = Beaming.pillar(t, motes: -1)
        switch t {
        case ..<0.55:
            hidden = true
        case ..<1.35:
            let p = CGFloat((t - 0.55) / 0.8)
            let e = Pose.ease(p)
            eyes = .closed
            left = .up
            right = .up
            lift = 16 * (1 - e)
            sx = 0.78 + 0.22 * e
            sy = 1.3 - 0.3 * e
            legLength = 1.5 - 0.3 * e
            glow = Double(0.85 * min(1, (1 - p) * 1.6))
            dissolve = 1 - p
        case ..<1.6:
            let k = sin(.pi * (t - 1.35) / 0.25)
            sx = 1 + 0.12 * k
            sy = 1 - 0.12 * k
            eyes = .closed
        case ..<2.0:
            look = Int((t - 1.6) / 0.13) % 2 == 0 ? -0.5 : 0.5
        default:
            eyes = .happy
            right = Int(clock / 0.18) % 2 == 0 ? .up : .diagUp
        }
    }
}
