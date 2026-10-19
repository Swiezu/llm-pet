import SwiftUI

enum HelloAI {
    static let duration = 6.6
}

extension Pose {
    mutating func helloAI(t: TimeInterval, clock: TimeInterval) {
        let antenna = point(6, -1.9)
        switch t {
        case ..<0.5:
            let pop = Pose.ease(CGFloat(t / 0.3))
            place(Art.antenna, antenna.x, antenna.y - 8 + 8 * pop, scale: 0.5 + 0.5 * pop)
            sy = 1 - 0.06 * sin(.pi * CGFloat(t / 0.5))
            eyes = .wide
        case ..<4.6:
            let step = Int((t - 0.5) / 0.3)
            eyes = .led
            right = step % 2 == 0 ? .up : .diagUp
            left = step % 4 == 3 ? .diagDown : .side
            dx = [0, 2, 0, -2][step % 4]
            tilt = [0, 3, 0, -3][step % 4]
            let lit = Int(clock / 0.2) % 2 == 0
            place(lit ? Art.antenna : Art.antennaOff, antenna.x, antenna.y)
            let tip = CGPoint(x: antenna.x, y: antenna.y + 11)
            for arc in 0..<3 {
                let p = CGFloat((clock / 1.2 + Double(arc) / 3).truncatingRemainder(dividingBy: 1))
                let radius = 8 + 30 * p
                for index in 0..<5 {
                    let angle = Double(index - 2) * 0.3
                    for side in [-1.0, 1.0] {
                        dot("t", tip.x + CGFloat(side) * radius * CGFloat(cos(angle)), tip.y + radius * CGFloat(sin(angle)) * 0.6, opacity: Double(1 - p))
                    }
                }
            }
            for digit in 0..<4 {
                let p = CGFloat((clock / 1.6 + Double(digit) / 4).truncatingRemainder(dividingBy: 1))
                let side: CGFloat = digit % 2 == 0 ? -1 : 1
                place(Art.binary[(digit + Int(clock)) % 2], side * (52 + CGFloat(digit) * 4), 20 + 70 * p, opacity: Double(sin(.pi * p)))
            }
        case ..<5.4:
            eyes = .happy
            right = .up
            place(Art.antenna, antenna.x, antenna.y)
            place(Art.sparkle[Int(clock / 0.1) % 2], antenna.x + 30, antenna.y + 4)
        default:
            let q = CGFloat((t - 5.4) / 1.2)
            eyes = .happy
            lift = q < 0.4 ? 10 * sin(.pi * q / 0.4) : 0
            if q < 0.5 { place(Art.antenna, antenna.x + 40 * q, antenna.y + 60 * q - 80 * q * q, opacity: Double(1 - q * 2)) }
        }
    }
}
