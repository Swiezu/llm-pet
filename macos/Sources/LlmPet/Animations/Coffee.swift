import SwiftUI

enum Coffee {
    static let duration = 7.2
}

extension Pose {
    private mutating func steam(from top: CGPoint, clock: TimeInterval, drift: CGFloat = 0) {
        for puff in 0..<3 {
            let p = CGFloat((clock / 1.1 + Double(puff) / 3).truncatingRemainder(dividingBy: 1))
            let x = top.x + 3.5 * CGFloat(puff - 1) + 3 * CGFloat(sin(Double(p) * 6 + Double(puff))) + drift * p
            dot("p", x, top.y + 6 + 22 * p, size: p < 0.5 ? 2 : 1, opacity: Double(0.85 * (1 - p)))
        }
    }

    mutating func coffee(t: TimeInterval, clock: TimeInterval) {
        let mugOnFloor = point(10 + 4.6, 6.2)
        switch t {
        case ..<0.5:
            let pop = Pose.ease(CGFloat(t / 0.3))
            right = .diagDown
            look = 0.4
            place(Art.mug, at: mugOnFloor, scale: 0.4 + 0.6 * pop)
            place(Art.kettle, at: point(10 + 1.6, 3.6), scale: 0.4 + 0.6 * pop)
        case ..<2.5:
            let p = CGFloat((t - 0.5) / 2.0)
            right = .diagUp
            look = 0.5
            lookY = 0.2
            let kettle = CGPoint(x: mugOnFloor.x + 16, y: mugOnFloor.y + 32)
            place(Art.kettle, at: kettle)
            place(p < 0.6 ? Art.mug : Art.mugFull, at: mugOnFloor)
            if p > 0.05 && p < 0.92 {
                let spout = CGPoint(x: kettle.x - 19, y: kettle.y + 1)
                let rows = Int((spout.y - mugOnFloor.y - 10) / 3.5)
                for row in 0..<max(0, rows) {
                    let wobble = CGFloat(sin(clock * 30 + Double(row))) * 1.2
                    dot("n", spout.x + wobble * CGFloat(row) / CGFloat(max(rows, 1)), spout.y - 3.5 * CGFloat(row), size: 2)
                }
            }
            if p > 0.6 { steam(from: mugOnFloor, clock: clock) }
        case ..<2.9:
            let q = CGFloat((t - 2.5) / 0.4)
            right = .diagDown
            sy = 1 - 0.08 * sin(.pi * q)
            look = 0.4
            lookY = 0.3
            let lifted = CGPoint(x: mugOnFloor.x + (point(6, 4.6).x - mugOnFloor.x) * Pose.ease(q), y: mugOnFloor.y + (point(6, 4.6).y - mugOnFloor.y) * Pose.ease(q))
            place(Art.mugFull, at: lifted)
            steam(from: lifted, clock: clock)
        case ..<3.4:
            left = .reach(0.3)
            right = .reach(0.3)
            eyes = .closed
            let mug = point(6, 4.6)
            place(Art.mugFull, at: mug)
            steam(from: mug, clock: clock, drift: 26)
        case ..<5.6:
            let sip = (t >= 3.6 && t < 4.3) || (t >= 4.8 && t < 5.4)
            left = .reach(sip ? 0.9 : 0.3)
            right = .reach(sip ? 0.9 : 0.3)
            eyes = sip ? .closed : .happy
            bob = sip ? 0.05 : 0
            let mug = sip ? point(7.4, 4.1) : point(6, 4.6)
            place(sip ? Art.mugTilted : Art.mugFull, at: mug)
            if !sip { steam(from: mug, clock: clock) }
        case ..<6.4:
            let q = CGFloat((t - 5.6) / 0.8)
            left = .reach(0.3)
            right = .reach(0.3)
            eyes = .happy
            heart = q
            sy = 1 - 0.04 * sin(.pi * q)
            place(Art.mug, at: point(6, 4.6))
        default:
            let q = (t - 6.4) / 0.8
            eyes = .happy
            place(Art.mug, at: point(6, 4.6), opacity: 1 - q)
        }
    }
}
