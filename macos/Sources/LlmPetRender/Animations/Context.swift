import SwiftUI

enum Context {
    static let fullDuration = 7.0
    static let compactDuration = 7.2
    static let tokens = 26
    static let onHead = 3

    static func slot(_ index: Int) -> CGPoint {
        let side: CGFloat = index % 2 == 0 ? -1 : 1
        let column = (index / 2) % 3
        let row = index / 6
        return CGPoint(x: side * (46 + 10.5 * CGFloat(column)) + side * CGFloat(row % 2) * 5, y: 5 + 10.5 * CGFloat(row))
    }
}

extension Pose {
    private mutating func pile(count: Int, squeeze: CGFloat = 0, target: CGPoint = .zero, opacity: Double = 1) {
        for index in 0..<count {
            let slot = Context.slot(index)
            let x = slot.x + (target.x - slot.x) * squeeze
            let y = slot.y + (target.y - slot.y) * squeeze
            place(Art.token[index % 4], x, y, opacity: opacity, scale: 1 - 0.5 * squeeze, behind: squeeze > 0)
        }
    }

    mutating func contextFull(t: TimeInterval, clock: TimeInterval) {
        let landed = (0..<Context.tokens).filter { t >= Double($0) * 0.12 + 0.45 }.count
        let fill = CGFloat(landed + Context.onHead * (t > 3.7 ? 1 : 0)) / CGFloat(Context.tokens + Context.onHead)
        let fade = t > 6.6 ? 1 - (t - 6.6) / 0.4 : 1
        let strain = min(1, fill * 1.2)
        sx = 1 + 0.12 * strain
        sy = 1 - 0.08 * strain
        eyes = fill < 0.4 ? .wide : fill < 0.95 ? .focused : .dizzy
        sweat = fill > 0.5
        look = CGFloat(sin(clock * 3)) * 0.3
        lookY = -0.3
        for index in 0..<Context.tokens {
            let spawn = Double(index) * 0.12
            guard t >= spawn else { continue }
            let slot = Context.slot(index)
            let p = CGFloat(min(1, (t - spawn) / 0.45))
            place(Art.token[index % 4], slot.x, 330 - (330 - slot.y) * p * p, opacity: fade)
        }
        for index in 0..<Context.onHead {
            let spawn = 3.25 + Double(index) * 0.15
            guard t >= spawn else { continue }
            let p = CGFloat(min(1, (t - spawn) / 0.4))
            let head = point(4.5 + CGFloat(index) * 1.6, -0.8 - CGFloat(index % 2) * 1.5)
            place(Art.token[(index + 1) % 4], head.x, 330 - (330 - head.y) * p * p, opacity: fade)
        }
        if t > 3.7 {
            let k = CGFloat(sin(.pi * min(1, (t - 3.7) / 0.3)))
            sy -= 0.08 * k
            steam = true
            stars = t > 4.4
            tilt = 4 * sin(clock * 5)
        }
        place(Pose.bar(fill, blink: fill >= 1 && Int(clock / 0.25) % 2 == 0), at: point(6, -4.6), opacity: fade)
    }

    mutating func contextCompact(t: TimeInterval, clock: TimeInterval) {
        let all = Context.tokens + Context.onHead
        let presses = [1.1, 2.2, 3.3]
        let done = presses.filter { t >= $0 }.count
        let squeeze = [0, 0.35, 0.65, 0.9][done] + (t >= 3.3 ? CGFloat(min(1, (t - 3.3) / 0.7)) * 0.1 : 0)
        let target = CGPoint(x: 52, y: 8)
        let fill: CGFloat = [1, 0.7, 0.45, 0.2][done]
        let barFade = t > 6.6 ? 1 - (t - 6.6) / 0.6 : 1
        switch t {
        case ..<0.6:
            eyes = .focused
            look = 0.5
            pile(count: all)
        case ..<4.0:
            let local = (t - 0.6).truncatingRemainder(dividingBy: 1.1)
            eyes = .focused
            look = 0.5
            dx = 30 * min(1, CGFloat(t - 0.6) * 3)
            if local < 0.35 {
                lift = 22 * CGFloat(sin(.pi / 2 * local / 0.35))
                left = .up
                right = .up
            } else if local < 0.5 {
                lift = 22 * CGFloat(1 - (local - 0.35) / 0.15)
                left = .reach(0)
                right = .reach(0)
            } else if local < 0.75 {
                let k = CGFloat(sin(.pi * (local - 0.5) / 0.25))
                sy = 1 - 0.2 * k
                sx = 1 + 0.15 * k
                left = .reach(0)
                right = .reach(0)
                dust = CGFloat((local - 0.5) / 0.4)
            }
            pile(count: all, squeeze: squeeze, target: target)
        case ..<4.6:
            let q = CGFloat((t - 4.0) / 0.6)
            dx = 30 * (1 - Pose.ease(q))
            eyes = .happy
            look = 0.5
            place(Art.zip, target.x, target.y + 6, scale: 0.6 + 0.4 * Pose.ease(q * 2))
            place(Art.sparkle[Int(clock / 0.1) % 2], target.x + 12, target.y + 26)
        case ..<5.4:
            let q = CGFloat((t - 4.6) / 0.8)
            right = .up
            eyes = .happy
            let hand = point(10 - 0.5, -3.25)
            place(Art.zip, target.x + (hand.x - target.x) * Pose.ease(q), target.y + 6 + (hand.y - target.y - 6) * Pose.ease(q), opacity: Double(1 - max(0, q - 0.7) / 0.3))
        default:
            let q = CGFloat((t - 5.4) / 1.8)
            eyes = q < 0.5 ? .closed : .happy
            sy = 1 - 0.05 * sin(.pi * min(1, q * 2))
            sx = 1 + 0.03 * sin(.pi * min(1, q * 2))
        }
        place(Pose.bar(fill), at: point(6 + dx / Style.unit, -4.6), opacity: barFade)
    }
}
