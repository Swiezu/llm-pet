import SwiftUI

enum PaperPlane {
    static let duration = 6.6
    static let release = 3.0
    static let flight = 2.6
}

extension Pose {
    mutating func paperPlane(t: TimeInterval, clock: TimeInterval) {
        if t >= PaperPlane.release && t < PaperPlane.release + PaperPlane.flight {
            let path = { (p: CGFloat) -> CGPoint in
                CGPoint(x: 40 + 130 * p, y: 50 + 150 * p - 55 * p * p + 16 * sin(p * .pi * 3))
            }
            let p = CGFloat((t - PaperPlane.release) / PaperPlane.flight)
            let now = path(p)
            let ahead = path(min(1, p + 0.02))
            let rising = ahead.y - now.y
            flying = Flying(
                kind: .plane,
                x: now.x,
                up: now.y,
                frame: rising > 1.2 ? 1 : rising < -0.3 ? 2 : 0,
                opacity: p > 0.6 ? Double(1 - (p - 0.6) / 0.4) : 1,
                trail: stride(from: 1, through: 4, by: 1).compactMap { step in
                    let back = p - CGFloat(step) * 0.035
                    return back > 0 ? path(back) : nil
                }
            )
        }
        switch t {
        case ..<0.6:
            left = .reach(0.2)
            right = .reach(0.2)
            paper = .sheet
            lookY = 0.3
        case ..<2.0:
            let step = Int((t - 0.6) / 0.47)
            let local = (t - 0.6).truncatingRemainder(dividingBy: 0.47) / 0.47
            left = .reach(local < 0.5 ? 0.6 : 0.2)
            right = .reach(local < 0.5 ? 0.2 : 0.6)
            paper = .folded(step)
            lookY = 0.3
            sy = 1 - 0.03 * CGFloat(sin(.pi * local))
        case ..<2.3:
            left = .reach(0.3)
            right = .reach(0.3)
            paper = .plane
            eyes = .happy
            look = 0.4
        case ..<2.9:
            let q = (t - 2.3) / 0.6
            tilt = -10 * sin(.pi / 2 * q)
            right = .up
            paper = .raised
            look = 0.5
            lookY = -0.3
        case ..<PaperPlane.release:
            tilt = -10
            right = .up
            paper = .raised
        case ..<3.15:
            let q = (t - PaperPlane.release) / 0.15
            tilt = -10 + 22 * q
            right = .diagUp
            look = 0.5
        case ..<3.5:
            tilt = 12 * (1 - (t - 3.15) / 0.35)
            right = .diagUp
            look = 0.5
            lookY = -0.2
        case ..<5.6:
            let p = CGFloat((t - PaperPlane.release) / PaperPlane.flight)
            look = 0.5
            lookY = -0.2 - 0.3 * p
            right = t > 4.2 && t < 5.0 ? .chin : .side
        default:
            eyes = .happy
            bob = Int((t - 5.6) / 0.2) % 2 == 0 ? 0.12 : 0
        }
    }
}
