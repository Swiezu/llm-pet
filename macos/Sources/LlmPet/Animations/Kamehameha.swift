import SwiftUI

enum Kamehameha {
    static let duration = 6.6
    static let fire = 2.85
    static let thrust = 2.6
    static let hands = CGPoint(x: 52, y: 29)
}

extension Pose {
    private mutating func stance() {
        sy = 0.9
        sx = 1.07
        legLength = 0.95
        legs = [0, 0.1, 0.1, 0]
    }

    mutating func kamehameha(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<0.6:
            let p = CGFloat(t / 0.6)
            sy = 1 - 0.1 * p
            sx = 1 + 0.07 * p
            legLength = 1.2 - 0.25 * p
            left = p < 0.5 ? .diagUp : .hidden
            right = p < 0.5 ? .diagUp : .hidden
            cup = p < 0.5 ? nil : .back
            eyes = .focused
            look = -0.3
        case ..<Kamehameha.thrust:
            let p = CGFloat((t - 0.6) / (Kamehameha.thrust - 0.6))
            stance()
            left = .hidden
            right = .hidden
            cup = .back
            charge = 0.6 + 2.2 * p
            rubble = p
            eyes = .focused
            look = -0.2
            dx = Int(clock / 0.04) % 2 == 0 ? 0.4 + 0.8 * p : -0.4 - 0.8 * p
            aura = 0.3 + 0.5 * p
            band = .none
        case ..<Kamehameha.fire:
            let q = CGFloat((t - Kamehameha.thrust) / (Kamehameha.fire - Kamehameha.thrust))
            stance()
            left = .hidden
            right = .hidden
            cup = .front
            charge = 2.8 - 0.8 * q
            eyes = .wide
            look = 0.4
            tilt = 6 * Double(q)
        case ..<5.0:
            let p = CGFloat((t - Kamehameha.fire) / (5.0 - Kamehameha.fire))
            stance()
            left = .hidden
            right = .hidden
            cup = .front
            eyes = .focused
            look = 0.4
            tilt = 6 - 11 * Double(min(1, p * 6))
            dx = -6 * min(1, p * 6) + (Int(clock / 0.035) % 2 == 0 ? 0.7 : -0.7)
            beam = Beam(thickness: min(1, CGFloat(t - Kamehameha.fire) / 0.1), length: min(1, CGFloat(t - Kamehameha.fire) / 0.18), flash: t - Kamehameha.fire < 0.25 ? CGFloat((t - Kamehameha.fire) / 0.25) : nil)
            rubble = 1
        case ..<5.6:
            let q = CGFloat((t - 5.0) / 0.6)
            stance()
            left = .hidden
            right = .hidden
            cup = .front
            eyes = .focused
            dx = -6
            tilt = -5 * Double(1 - q)
            beam = Beam(thickness: (1 - q) * (1 - q), length: 1)
        default:
            let q = (t - 5.6) / 1.0
            dx = -6 * CGFloat(1 - q)
            eyes = .closed
            sy = 0.96 + 0.04 * CGFloat(sin(clock * 12))
            left = .side
            right = .side
            steam = q < 0.6
        }
    }
}
