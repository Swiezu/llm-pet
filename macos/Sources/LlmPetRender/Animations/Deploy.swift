import SwiftUI

enum Deploy {
    static let duration = 7.6
    static let rocketX: CGFloat = 82
}

extension Pose {
    mutating func deploy(t: TimeInterval, clock: TimeInterval) {
        let pad = CGPoint(x: Deploy.rocketX, y: 28)
        var rocket = pad
        var shake: CGFloat = 0
        switch t {
        case ..<0.5:
            let pop = Pose.ease(CGFloat(t / 0.35))
            place(Art.rocket, at: rocket, scale: 0.3 + 0.7 * pop)
            if t > 0.3 { dust = CGFloat((t - 0.3) / 0.4) }
            look = 0.5
            eyes = .wide
            return
        case ..<1.2:
            right = .reach(0.3)
            look = 0.5
            eyes = .happy
            place(Art.remote, at: point(10 + 0.8, 3.6))
        case ..<2.7:
            let count = 3 - Int((t - 1.2) / 0.5)
            let local = CGFloat((t - 1.2).truncatingRemainder(dividingBy: 0.5) / 0.5)
            right = .reach(0.3)
            look = 0.5
            lookY = -0.2
            eyes = .wide
            sweat = true
            dx = Int(clock / 0.05) % 2 == 0 ? 0.4 : -0.4
            place(Art.remote, at: point(10 + 0.8, 3.6))
            if let digit = Art.digits[max(1, count)] {
                place(digit, rocket.x, rocket.y + 44, opacity: Double(1 - local * 0.6), scale: 1.4 - 0.4 * Pose.ease(local * 3))
            }
        case ..<3.3:
            let q = CGFloat((t - 2.7) / 0.6)
            right = .reach(q < 0.2 ? -0.2 : 0.3)
            sy = q < 0.25 ? 0.9 : 1
            look = 0.5
            eyes = .wide
            place(Art.remote, at: point(10 + 0.8, 3.6))
            shake = Int(clock / 0.03) % 2 == 0 ? 1.5 : -1.5
            rocket.y = pad.y + 4 * q
            for index in 0..<7 {
                let spread = (10 + 34 * q) * CGFloat(index - 3) / 3
                place(index % 2 == 0 ? Art.puffBig : Art.puff, pad.x + spread, 9 + 6 * q * CGFloat(abs(index - 3)) / 3, opacity: Double(0.95 - 0.3 * q))
            }
            place(Art.flames[Int(clock / 0.06) % 2], pad.x, rocket.y - 34, scale: 0.6 + 0.6 * q)
        case ..<5.0:
            let p = CGFloat((t - 3.3) / 1.7)
            rocket.y = pad.y + 380 * p * p
            look = 0.4
            lookY = -0.2 - 0.4 * min(1, p * 1.5)
            eyes = .wide
            sy = 1 - 0.05 * sin(.pi * min(1, p * 2))
            place(Art.flameBig[Int(clock / 0.05) % 2], rocket.x, rocket.y - 42)
            for index in 1...6 {
                let back = max(0, p - CGFloat(index) * 0.06)
                let height = pad.y + 380 * back * back - 40
                place(index < 3 ? Art.puffBig : Art.puff, rocket.x + CGFloat(index % 2 == 0 ? 4 : -4), max(10, height), opacity: Double(0.9 - CGFloat(index) * 0.1))
            }
            for index in 0..<3 {
                place(Art.puffBig, pad.x + CGFloat(index - 1) * 26, 10, opacity: Double(0.8 * (1 - p)))
            }
        case ..<5.6:
            let q = (t - 5.0) / 0.6
            look = 0.4
            lookY = -0.6
            eyes = .open
            place(Art.sparkle[Int(clock / 0.1) % 2], rocket.x - 10, 296, opacity: 1 - q)
        default:
            let q = CGFloat((t - 5.6) / 2.0)
            eyes = .happy
            left = Int(clock / 0.2) % 2 == 0 ? .up : .side
            right = Int(clock / 0.2) % 2 == 0 ? .side : .up
            lift = q < 0.7 ? 10 * abs(CGFloat(sin((t - 5.6) * 7))) : 0
            place(Art.check, at: point(6, -3.6), scale: min(1.2, 0.4 + 2 * q))
        }
        if t < 5.0 { place(Art.rocket, rocket.x + shake, rocket.y) }
    }
}
