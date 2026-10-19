import SwiftUI

enum PowerUp {
    static let duration = 7.6
    static let transform = 2.4
    static let powerDown = 6.0
}

extension Pose {
    private mutating func transformed() {
        hair = 1
        ssj = true
        flames = 1
        sparks = true
    }

    mutating func powerUp(t: TimeInterval, clock: TimeInterval) {
        let shake = Int(clock / 0.035) % 2 == 0 ? 1.0 : -1.0
        switch t {
        case ..<0.5:
            let p = CGFloat(t / 0.5)
            sy = 1 - 0.1 * p
            sx = 1 + 0.07 * p
            legLength = 1.2 - 0.25 * p
            left = .tucked
            right = .tucked
            eyes = .focused
            dx = CGFloat(shake) * 0.4
        case ..<PowerUp.transform:
            let p = CGFloat((t - 0.5) / (PowerUp.transform - 0.5))
            sy = 0.9 + 0.02 * CGFloat(sin(clock * 30))
            sx = 1.07
            legLength = 0.95
            left = .tucked
            right = .tucked
            eyes = .focused
            dx = CGFloat(shake) * (0.5 + 1.6 * p)
            flames = (0.2 + 0.8 * p) * (0.85 + 0.15 * CGFloat(sin(clock * 23)))
            sparks = p > 0.35
            rubble = p
            hair = p > 0.6 && sin(clock * 37) > 0.2 ? 0.45 : 0
            steam = p < 0.4
        case ..<2.75:
            let q = CGFloat((t - PowerUp.transform) / 0.35)
            transformed()
            hair = q < 0.5 ? 1.25 : 1.25 - 0.5 * (q - 0.5)
            eyes = .wide
            sy = 1 + 0.08 * sin(.pi * q)
            sx = 1 - 0.04 * sin(.pi * q)
            left = .tucked
            right = .tucked
            shockwave = CGFloat((t - PowerUp.transform) / 0.7)
            rubble = 1
        case ..<PowerUp.powerDown:
            let q = CGFloat((t - 2.75) / (PowerUp.powerDown - 2.75))
            transformed()
            eyes = .focused
            left = .tucked
            right = .tucked
            lift = 7 * min(1, q * 5) * min(1, (1 - q) * 6) + 1.5 * CGFloat(sin(clock * 4))
            dx = CGFloat(shake) * 0.5
            sy = 1.02 + 0.02 * CGFloat(sin(clock * 6))
            shockwave = t < 3.1 ? CGFloat((t - PowerUp.transform) / 0.7) : nil
            rubble = 1
        default:
            let q = CGFloat((t - PowerUp.powerDown) / (PowerUp.duration - PowerUp.powerDown))
            hair = max(0, 1 - 1.6 * q)
            flames = max(0, 0.8 * (1 - 2 * q))
            ssj = q < 0.5
            eyes = q < 0.5 ? .focused : .closed
            sy = 0.96 + 0.04 * CGFloat(sin(clock * 12))
            steam = q > 0.3 && q < 0.9
        }
    }
}
