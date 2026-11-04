import SwiftUI

enum Bird {
    static let awayDuration = 2.5
    static let inDuration = 2.7

    static func frame(_ clock: TimeInterval, rate: Double = 0.08) -> PixelArt {
        Art.bird[[0, 1, 2, 1][Int(clock / rate) % 4]]
    }
}

extension Pose {
    mutating func flyAway(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<0.4:
            look = 0.5
            lookY = -0.4
            eyes = .wide
            exclaim = t > 0.1
        case ..<0.55:
            sx = 1.1
            sy = 0.86
            eyes = .happy
            left = .flail
            right = .flail
        case ..<0.68:
            lift = 24 * CGFloat((t - 0.55) / 0.13)
            sx = 0.9
            sy = 1.15
            eyes = .closed
            left = .up
            right = .up
            legLength = 1.5
        default:
            hidden = true
        }
        puff(CGFloat((t - 0.62) / 0.9), clock: clock, size: 0.7, up: 50)
        guard t >= 0.66 else { return }
        let q = CGFloat((t - 0.66) / 1.84)
        place(Bird.frame(clock), 210 * pow(q, 1.3), 50 + 250 * pow(q, 1.6) + 5 * CGFloat(sin(clock * 20)), opacity: Double(min(1, (1 - q) * 5)))
        let f = CGFloat((t - 0.75) / 1.5)
        if f > 0, f < 1 { dot("c", 6 + 12 * CGFloat(sin(Double(f) * 7)), 56 - 50 * f, opacity: Double(1 - f)) }
    }

    mutating func flyIn(t: TimeInterval, clock: TimeInterval) {
        puff(CGFloat((t - 1.55) / 0.9), clock: clock, size: 1, up: 26)
        switch t {
        case ..<1.35:
            hidden = true
            let q = CGFloat(t / 1.35)
            let e = 1 - (1 - q) * (1 - q)
            place(Bird.frame(clock, rate: 0.07), -200 * (1 - e), 14 + 290 * pow(1 - q, 1.6) + 5 * CGFloat(sin(clock * 18)) * (1 - q), opacity: Double(min(1, q * 6)))
        case ..<1.66:
            hidden = true
            let q = (t - 1.35) / 0.27
            place(Art.bird[q < 0.5 ? 0 : 1], 0, 14 + 7 * CGFloat(sin(.pi * q)))
        case ..<2.2:
            eyes = .closed
            sx = 1 + 0.05 * CGFloat(sin(clock * 30))
            tilt = 5 * sin(clock * 30)
            let f = CGFloat((t - 1.66) / 0.54)
            dot("c", -8 + 10 * CGFloat(sin(Double(f) * 6)), 60 - 52 * f, opacity: Double(1 - f))
        default:
            eyes = .happy
            look = Int((t - 2.2) / 0.16) % 2 == 0 ? -0.4 : 0.4
            right = .up
        }
    }
}
