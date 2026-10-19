import SwiftUI

enum ShipIt {
    static let duration = 7.4
    static let box = CGPoint(x: 58, y: 17)
}

extension Pose {
    private mutating func sea(_ shipX: CGFloat, _ clock: TimeInterval, cargo: Bool, bob: CGFloat) {
        place(Art.ship, shipX, 22 + bob)
        if cargo { place(Art.boxTaped, shipX - 4, 54 + bob, scale: 0.6) }
        place(Art.wave[Int(clock / 0.3) % 2], shipX, 4)
    }

    mutating func shipIt(t: TimeInterval, clock: TimeInterval) {
        let box = ShipIt.box
        let rock = 1.5 * CGFloat(sin(clock * 5))
        switch t {
        case ..<0.5:
            place(Art.boxOpen, box.x, box.y, scale: 0.4 + 0.6 * Pose.ease(CGFloat(t / 0.3)))
            look = 0.5
        case ..<1.5:
            let q = CGFloat((t - 0.5) / 1.0)
            right = q < 0.6 ? .up : .diagUp
            look = 0.5
            lookY = 0.2
            let hand = point(10 - 0.5, -3.0)
            let drop = Pose.ease(max(0, q - 0.5) * 2)
            place(Art.code, hand.x + (box.x - hand.x) * drop, hand.y + (box.y + 8 - hand.y) * drop + 20 * sin(.pi * drop), opacity: drop > 0.95 ? 0 : 1)
            place(Art.boxOpen, box.x, box.y)
        case ..<2.3:
            let beat = Int((t - 1.5) / 0.18) % 2
            left = .reach(beat == 0 ? 0.5 : 0.1)
            right = .reach(beat == 0 ? 0.1 : 0.5)
            dx = 14
            look = 0.5
            lookY = 0.3
            place(t < 1.8 ? Art.boxOpen : t < 2.0 ? Art.boxClosed : Art.boxTaped, box.x, box.y)
        case ..<2.8:
            let slam = t >= 2.55
            dx = 14
            right = slam ? .reach(0) : .up
            sy = slam ? 1 - 0.1 * CGFloat(sin(.pi * (t - 2.55) / 0.25)) : 1
            eyes = slam ? .closed : .focused
            look = 0.5
            place(Art.boxTaped, box.x, box.y)
            if slam {
                place(Art.check, box.x + 2, box.y + 2, scale: 0.8)
                dust = CGFloat((t - 2.55) / 0.4)
            }
        case ..<3.6:
            let q = CGFloat((t - 2.8) / 0.8)
            dx = 14 * (1 - Pose.ease(q))
            look = 0.5
            eyes = .wide
            place(Art.boxTaped, box.x, box.y)
            place(Art.check, box.x + 2, box.y + 2, scale: 0.8)
            sea(220 - 120 * Pose.ease(q), clock, cargo: false, bob: rock)
        case ..<4.1:
            let q = CGFloat((t - 3.6) / 0.5)
            right = .up
            left = .up
            look = 0.5
            sea(100, clock, cargo: q >= 1, bob: rock)
            let arc = Pose.ease(q)
            place(Art.boxTaped, box.x + (96 - box.x) * arc, box.y + (54 - box.y) * arc + 40 * sin(.pi * arc), scale: 1 - 0.4 * arc)
        case ..<6.0:
            let q = CGFloat((t - 4.1) / 1.9)
            right = .chin
            eyes = .happy
            look = 0.5
            sea(100 + 150 * q * q, clock, cargo: true, bob: rock)
        default:
            eyes = .happy
            right = Int(clock / 0.18) % 2 == 0 ? .up : .diagUp
            lift = 9 * abs(CGFloat(sin((t - 6.0) * 7)))
            place(Art.sparkle[Int(clock / 0.1) % 2], 40, 70)
            place(Art.sparkle[(Int(clock / 0.1) + 1) % 2], -40, 80)
        }
    }
}
