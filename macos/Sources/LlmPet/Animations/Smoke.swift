import SwiftUI

enum Smoke {
    static let duration = 8.8
}

extension Pose {
    private static func lerp(_ a: CGPoint, _ b: CGPoint, _ p: CGFloat) -> CGPoint {
        let e = ease(p)
        return CGPoint(x: a.x + (b.x - a.x) * e, y: a.y + (b.y - a.y) * e)
    }

    private mutating func wisp(from tip: CGPoint, clock: TimeInterval) {
        for puff in 0..<3 {
            let p = CGFloat((clock / 1.5 + Double(puff) / 3).truncatingRemainder(dividingBy: 1))
            place(Art.wisp, tip.x + 3 * CGFloat(sin(Double(p) * 7 + Double(puff) * 2)), tip.y + 5 + 28 * p, opacity: Double(0.8 * (1 - p)))
        }
    }

    private mutating func exhale(from mouth: CGPoint, _ p: CGFloat) {
        for puff in 0..<6 {
            let q = p * 1.5 - CGFloat(puff) * 0.1
            guard q > 0, q < 1 else { continue }
            let drift = 3 * CGFloat(sin(Double(q) * 6 + Double(puff)))
            place(Art.puff, mouth.x + 8 + 30 * q + drift, mouth.y + 2 + 18 * q + CGFloat(puff % 3) * 3, opacity: Double(0.9 * (1 - q)), scale: 0.6 + 0.7 * q)
        }
    }

    mutating func smoke(t: TimeInterval, clock: TimeInterval) {
        let mouth = point(8.8, 4.5)
        let corner = point(7.4, 4.4)
        let hand = point(12.6, 3.4)
        let floor = point(10.4, 7.2)
        let glow = Art.cigaretteLit[Int(clock / 0.2) % 2]
        func tip(_ center: CGPoint) -> CGPoint { CGPoint(x: center.x + 3.5 * Style.unit / 2, y: center.y) }
        switch t {
        case ..<0.5:
            right = .diagDown
            look = 0.4
            lookY = 0.3
        case ..<0.9:
            let p = CGFloat((t - 0.5) / 0.4)
            right = .reach(0.4)
            look = 0.5
            place(Art.cigarette, at: hand, scale: 0.4 + 0.6 * Pose.ease(p * 2))
        case ..<1.3:
            let p = CGFloat((t - 0.9) / 0.4)
            right = .reach(0.4 + 0.5 * Pose.ease(p))
            look = 0.4
            place(Art.cigarette, at: Pose.lerp(hand, mouth, p))
        case ..<1.55:
            right = .diagDown
            look = 0.4
            lookY = 0.3
            place(Art.cigarette, at: mouth)
        case ..<2.45:
            let lit = t > 2.05
            right = .reach(0.2)
            look = 0.6
            lookY = 0.35
            eyes = lit ? .happy : .open
            place(Art.lighter, at: point(11.6, 5.6))
            if t > 1.7 && t < 2.25 { place(Art.lighterFlame[Int(clock / 0.08) % 2], at: point(11.7, 4.7)) }
            place(lit ? glow : Art.cigarette, at: mouth)
            if lit { wisp(from: tip(mouth), clock: clock) }
        case ..<2.65:
            right = .diagDown
            place(glow, at: mouth)
            wisp(from: tip(mouth), clock: clock)
        case ..<3.6:
            let p = CGFloat((t - 2.65) / 0.95)
            eyes = .closed
            sy = 1 + 0.05 * Pose.ease(p)
            sx = 1 - 0.02 * Pose.ease(p)
            place(Art.cigaretteHot, at: mouth)
        case ..<4.7:
            let p = CGFloat((t - 3.6) / 1.1)
            eyes = .happy
            sy = 1.05 - 0.08 * Pose.ease(p)
            sx = 0.98 + 0.03 * Pose.ease(p)
            place(glow, at: mouth)
            exhale(from: corner, p)
        case ..<5.1:
            let p = CGFloat((t - 4.7) / 0.4)
            right = .reach(0.9 - 0.5 * Pose.ease(p))
            eyes = .happy
            let cigarette = Pose.lerp(mouth, hand, p)
            place(glow, at: cigarette)
            wisp(from: tip(cigarette), clock: clock)
        case ..<6.3:
            let p = CGFloat((t - 5.1) / 1.2)
            right = .reach(0.4)
            eyes = t < 5.5 ? .closed : .happy
            look = 0.2
            place(glow, at: hand)
            wisp(from: tip(hand), clock: clock)
            if p < 0.8 { place(Art.smokeRing, corner.x + 22 + 12 * p, corner.y + 16 + 36 * p, opacity: Double(1 - p / 0.8), scale: 0.6 + 0.8 * p) }
        case ..<6.6:
            let p = CGFloat((t - 6.3) / 0.3)
            right = .reach(0.4 + 0.5 * Pose.ease(p))
            place(glow, at: Pose.lerp(hand, mouth, p))
        case ..<7.0:
            eyes = .closed
            sy = 1.04
            place(Art.cigaretteHot, at: mouth)
        case ..<7.4:
            let p = CGFloat((t - 7.0) / 0.4)
            right = .reach(0.9 - 0.5 * Pose.ease(p))
            eyes = .happy
            exhale(from: corner, p * 0.7)
            place(glow, at: Pose.lerp(mouth, hand, p))
        case ..<7.85:
            let p = CGFloat((t - 7.4) / 0.45)
            right = .side
            look = 0.5
            lookY = 0.4
            exhale(from: corner, 0.7 + p * 0.3)
            let fall = CGPoint(x: hand.x + (floor.x - hand.x) * p, y: hand.y + (floor.y - hand.y) * p * p)
            place(Art.butt, at: fall)
        case ..<8.35:
            let q = (t - 7.85) / 0.25
            let stomp = CGFloat(sin(.pi * q.truncatingRemainder(dividingBy: 1)))
            look = 0.5
            lookY = 0.4
            legs[3] = 0.7 * stomp
            sy = 1 - 0.03 * stomp
            if q > 0.5 { dust = CGFloat((q - 0.5).truncatingRemainder(dividingBy: 1)) }
            place(q < 0.5 ? Art.butt : Art.buttFlat, at: floor)
        default:
            let p = CGFloat((t - 8.35) / 0.45)
            eyes = .happy
            sy = 1 - 0.04 * sin(.pi * p)
            place(Art.buttFlat, at: floor, opacity: Double(1 - p))
        }
    }
}
