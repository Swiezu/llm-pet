import SwiftUI

enum Messages {
    static let staleDuration = 7.4
    static let handoffDuration = 7.0
    static let limitDuration = 6.8
    static let pixel: CGFloat = Style.unit / 2
}

extension Art {
    fileprivate static let msgRod = PixelArt(rows: [
        "kkkkkkkkkkkk",
        "knmmmmmmmmnk",
        "knmsmmsmmmnk",
        "kkkkkkkkkkkk",
    ])
    fileprivate static let msgRodTilted = PixelArt(rows: [
        ".......kkk",
        ".....kkmnk",
        "...kkmmmk.",
        ".kkmmsmk..",
        "knmmmkk...",
        "kkkkk.....",
    ])
    fileprivate static let msgRoll = [
        PixelArt(rows: ["..kkkk..", ".kmmmmk.", "kmmnnmmk", "kmnmmnmk", "kmnmmnmk", "kmmnnmmk", ".kmmmmk.", "..kkkk.."]),
        PixelArt(rows: ["..kkkk..", ".kmmmmk.", "kmnnmmmk", "kmmmnmmk", "kmnmmnmk", "kmmnnmmk", ".kmmmmk.", "..kkkk.."]),
    ]
    fileprivate static let msgWeb = PixelArt(rows: [
        "x.....x.....x",
        ".x....x....x.",
        "..x..hxh..x..",
        "...xhhxhhx...",
        "hhhhx.x.xhhhh",
        "...xhhxhhx...",
        "..x..hxh..x..",
        ".x....x....x.",
        "x.....x.....x",
    ])
    fileprivate static let msgDust = [
        PixelArt(rows: [".vv.", "vuuv", "vuuv", ".vv."]),
        PixelArt(rows: ["..vv..", ".vuuv.", "vuuuuv", "vuuuuv", ".vuuv.", "..vv.."]),
    ]
    fileprivate static let msgWind = PixelArt(rows: ["aaaa..", "..aaaa"])
    fileprivate static let msgBriefcase = PixelArt(rows: [
        "...kkkk...",
        "...k..k...",
        "kkkkkkkkkk",
        "kbbbbbbbbk",
        "kbbbyybbbk",
        "knnnnnnnnk",
        "kbbbbbbbbk",
        "kkkkkkkkkk",
    ])
    fileprivate static let msgStop = PixelArt(rows: [
        "...kkkkkk...",
        "..kiiiiiik..",
        ".kiqqqqqqik.",
        "kiqqqqqqqqik",
        "kiqqqqqqqqik",
        "kiqiiiiiiqik",
        "kiqiiiiiiqik",
        "kiqqqqqqqqik",
        "kiqqqqqqqqik",
        ".kiqqqqqqik.",
        "..kiiiiiik..",
        "...kkkkkk...",
        ".....kk.....",
        ".....jj.....",
        ".....jj.....",
        ".....jj.....",
        ".....jj.....",
        ".....jj.....",
        ".....jj.....",
        ".....jj.....",
        ".....jj.....",
        ".....jj.....",
        ".....kk.....",
    ])

    fileprivate static func msgSheet(_ count: Int) -> PixelArt {
        let lengths = [4, 3, 5, 2, 4, 3]
        let rows = (0..<count).map { row -> String in
            guard row % 2 == 1 else { return "kmmmmmmk" }
            let length = lengths[(row / 2) % lengths.count]
            return "km" + String(repeating: "s", count: length) + String(repeating: "m", count: 5 - length) + "k"
        }
        return PixelArt(rows: rows)
    }

    fileprivate static func msgStrip(_ count: Int, staleFrom: Int) -> PixelArt {
        let edge = String(repeating: "k", count: count)
        let lines = (1...3).map { line in
            (0..<count).map { column -> String in
                let stale = column >= staleFrom
                if stale && (column * 7 + line * 5) % 9 == 0 { return "x" }
                let word = (column + line * 2) % 7
                if line != 2 && word < 5 && word != 2 { return stale ? "v" : "s" }
                return stale ? "u" : "m"
            }.joined()
        }
        return PixelArt(rows: [edge] + lines + [edge])
    }

    fileprivate static func msgBuddy(step: Int?, eyes: Int, facing: Int, armUp: Bool) -> PixelArt {
        var grid = Array(repeating: Array(repeating: Character("."), count: 24), count: 18)
        func fill(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ color: Character) {
            for row in y..<(y + h) where row >= 0 && row < 18 {
                for column in x..<(x + w) where column >= 0 && column < 24 { grid[row][column] = color }
            }
        }
        fill(4, 3, 16, 12, "t")
        fill(4, 14, 16, 1, "a")
        fill(4, 3, 4, 1, "i")
        fill(4, 4, 1, 1, "i")
        let waving = facing > 0 ? 18 : 4
        for side in [0, 20] {
            let near = side == 0 ? 4 : 18
            if armUp && near == waving {
                fill(near, 0, 2, 3, "t")
            } else {
                fill(side, 9, 4, 3, "t")
                fill(side, 11, 4, 1, "a")
            }
        }
        for (index, column) in [4, 8, 14, 18].enumerated() {
            let lifted = step.map { index % 2 == $0 } ?? false
            fill(column, 15, 2, lifted ? 1 : 2, "t")
            fill(column, lifted ? 16 : 17, 2, 1, "a")
        }
        for column in [6, 16] {
            let x = column + facing
            switch eyes {
            case 1:
                fill(x, 8, 1, 1, "k")
                fill(x + 1, 7, 1, 1, "k")
                fill(x + 2, 8, 1, 1, "k")
            case 2:
                fill(x, 9, 2, 1, "k")
            default:
                fill(x, 7, 2, 3, "k")
                fill(x, 7, 1, 1, "w")
            }
        }
        return PixelArt(rows: grid.map { String($0) })
    }
}

extension Pose {
    fileprivate static func msgArc(_ from: CGPoint, _ to: CGPoint, _ p: CGFloat, height: CGFloat) -> CGPoint {
        CGPoint(x: from.x + (to.x - from.x) * p, y: from.y + (to.y - from.y) * p + height * sin(.pi * p))
    }

    fileprivate static func msgStep(_ t: TimeInterval, _ start: Double, _ length: Double) -> CGFloat {
        CGFloat(min(1, max(0, (t - start) / length)))
    }

    fileprivate mutating func msgSit(_ amount: CGFloat) {
        bob = 0.85 * amount
        legLength = 1.2 - 0.85 * amount
    }

    fileprivate mutating func msgDustPaws(_ local: TimeInterval) {
        let beat = Int(local / 0.14)
        left = .reach(beat % 2 == 0 ? 0.45 : 0.1)
        right = .reach(beat % 2 == 0 ? 0.1 : 0.45)
        eyes = .closed
        for (side, hand) in [(-1.0, point(0.6, 3.6)), (1.0, point(11.4, 3.6))] {
            for mote in 0..<2 {
                let phase = CGFloat((local / 0.45 + Double(mote) / 2).truncatingRemainder(dividingBy: 1))
                place(Art.msgDust[0], hand.x + CGFloat(side) * 8 * phase, hand.y + 16 * phase, opacity: Double(0.85 * (1 - phase)), scale: 0.7)
            }
        }
    }

    mutating func stale(t: TimeInterval, clock: TimeInterval) {
        let pixel = Messages.pixel
        let staleX: CGFloat = 100
        let rollEnd: CGFloat = 150
        let hand = point(9.5, -1.5)
        var hanging: CGFloat = 0
        var ground: CGFloat = 0
        var web: (x: CGFloat, up: CGFloat, opacity: Double)?
        var scroll = true
        var spin = false
        switch t {
        case ..<0.4:
            right = .reach(0.3)
            look = 0.5
            eyes = .happy
            let reach = point(11.4, 3.4)
            place(Art.msgRod, at: reach, scale: 0.4 + 0.6 * Pose.ease(CGFloat(t / 0.3)))
            scroll = false
        case ..<0.8:
            let p = Pose.ease(Pose.msgStep(t, 0.4, 0.4))
            right = p < 0.5 ? .reach(0.3 + p) : .up
            look = 0.5
            lookY = -0.3 * p
            let reach = point(11.4, 3.4)
            place(Art.msgRod, reach.x + (hand.x + 12 - reach.x) * p, reach.y + (hand.y + 2 - reach.y) * p)
            scroll = false
        case ..<1.5:
            let p = Pose.msgStep(t, 0.8, 0.7)
            right = .up
            hanging = p * p
            look = 0.5
            lookY = 0.35 * p
        case ..<3.1:
            let p = Pose.msgStep(t, 1.5, 1.6)
            right = .up
            hanging = 1
            ground = 1 - (1 - p) * (1 - p)
            spin = p < 0.97
            look = 0.5
            lookY = 0.35
            eyes = p > 0.55 ? .focused : .open
            tilt = 2 * Double(p)
            if t < 1.75 { place(Art.puffBig, hand.x + 12 + 14, 6, opacity: Double(1 - (t - 1.5) / 0.25), scale: 0.8) }
        case ..<4.1:
            let p = Pose.msgStep(t, 3.1, 1.0)
            right = .up
            hanging = 1
            ground = 1
            look = 0.5
            lookY = 0.3
            eyes = .wide
            exclaim = t < 3.6
            sweat = t > 3.4
            sy = 1 + 0.05 * CGFloat(sin(.pi * min(1, (t - 3.1) / 0.3)))
            tilt = 2 * Double(1 - p)
            web = (rollEnd - 12, 18, Double(Pose.ease(p * 3)))
        case ..<5.0:
            let p = Pose.msgStep(t, 4.1, 0.9)
            right = .up
            left = .reach(Int(clock / 0.12) % 2 == 0 ? 0.4 : 0.9)
            eyes = .focused
            sweat = true
            look = 0.5
            lookY = 0.3 * (1 - p)
            ground = p < 0.55 ? 1 - Pose.ease(p / 0.55) : 0
            hanging = p < 0.55 ? 1 : 1 - Pose.ease((p - 0.55) / 0.45)
            spin = true
        case ..<5.9:
            let p = Pose.msgStep(t, 5.0, 0.9)
            scroll = false
            look = 0.5
            let high = CGPoint(x: hand.x + 12, y: hand.y + 2)
            let front = point(13.4, 3.0)
            let bring = Pose.ease(min(1, p / 0.22))
            right = bring < 0.5 ? .up : .reach(0.3)
            let rod = CGPoint(x: high.x + (front.x - high.x) * bring, y: high.y + (front.y - high.y) * bring)
            if p > 0.25 && p < 0.8 {
                eyes = .closed
                sx = 1.05
                sy = 0.97
                let mouth = point(10.6, 3.4)
                for puff in 0..<3 {
                    let phase = CGFloat(((t - 5.2) / 0.3 + Double(puff) / 3).truncatingRemainder(dividingBy: 1))
                    place(Art.msgWind, mouth.x + 4 + 14 * phase, mouth.y + 2 * CGFloat(puff - 1) + 2 * phase, opacity: Double(0.9 * (1 - phase * phase)))
                }
            } else {
                eyes = p < 0.25 ? .open : .happy
            }
            place(Art.msgRod, at: rod)
            let blown = Pose.ease(max(0, p - 0.3) / 0.7)
            web = (rod.x + 4 + 80 * blown, rod.y + 4 + 46 * blown, Double(1 - blown))
            for mote in 0..<5 where p > 0.25 {
                let angle = Double(mote) * 0.45 - 0.5
                place(Art.msgDust[mote % 2], rod.x + 6 + 50 * blown * CGFloat(cos(angle)), rod.y + 2 + 50 * blown * CGFloat(sin(angle)), opacity: Double(0.9 * (1 - blown)), scale: 0.8)
            }
        case ..<6.15:
            let p = Pose.ease(Pose.msgStep(t, 5.9, 0.25))
            right = .reach(0.3 - 0.5 * p)
            scroll = false
            tilt = -4 * Double(p)
            look = 0.5
            eyes = .focused
            let front = point(13.4, 3.0)
            place(Art.msgRod, front.x - 6 * p, front.y - 3 * p)
        case ..<6.7:
            let p = Pose.msgStep(t, 6.15, 0.55)
            right = p < 0.5 ? .diagUp : .side
            scroll = false
            tilt = 4 * Double(1 - p)
            look = 0.5
            lookY = -0.4 * p
            eyes = .happy
            let front = point(13.4, 3.0)
            let at = Pose.msgArc(CGPoint(x: front.x - 6, y: front.y - 3), CGPoint(x: 220, y: 240), p, height: 40)
            place(Int(clock / 0.06) % 2 == 0 ? Art.msgRod : Art.msgRodTilted, at: at)
        default:
            scroll = false
            if t < 7.15 { msgDustPaws(t - 6.7) } else { eyes = .happy }
        }
        guard scroll else {
            if let web { place(Art.msgWeb, web.x, web.up, opacity: web.opacity) }
            return
        }
        let rod = CGPoint(x: hand.x + 12, y: hand.y + 2)
        let top = rod.y - 2 * pixel
        let column = rod.x
        let rows = Int(top * hanging / pixel)
        if rows > 0 { place(Art.msgSheet(rows), column, top - CGFloat(rows) * pixel / 2, behind: true) }
        let start = column + 4 * pixel
        let length = (rollEnd - start) * ground
        let columns = Int(length / pixel)
        if columns > 0 {
            let staleFrom = Int((staleX - start) / pixel)
            place(Art.msgStrip(columns, staleFrom: staleFrom), start + CGFloat(columns) * pixel / 2, 2.5 * pixel)
        }
        place(Art.msgRod, at: rod)
        let frame = spin ? Int(clock / 0.08) % 2 : 0
        if ground > 0 || (hanging >= 1 && t >= 1.5 && t < 4.1) {
            place(Art.msgRoll[frame], start + length, 4 * pixel)
        } else if rows > 0 {
            place(Art.msgRod, column, top - CGFloat(rows) * pixel - 2 * pixel)
        }
        if t >= 3.1 && t < 4.1 {
            for puff in 0..<3 {
                let phase = CGFloat(((t - 3.1) / 0.8 + Double(puff) / 3).truncatingRemainder(dividingBy: 1))
                let x = staleX + 8 + CGFloat(puff) * 14
                place(Art.msgDust[puff % 2], x + 4 * CGFloat(sin(Double(phase) * 6)), 14 + 40 * phase, opacity: Double(0.9 * (1 - phase)))
            }
        }
        if t >= 4.1 && t < 5.0 {
            let carried = ground > 0 ? CGPoint(x: start + length - 4, y: 18) : CGPoint(x: column + 24, y: top - CGFloat(rows) * pixel)
            place(Art.msgWeb, carried.x, carried.y)
        }
        if let web { place(Art.msgWeb, web.x, web.up, opacity: web.opacity) }
    }

    mutating func handoff(t: TimeInterval, clock: TimeInterval) {
        let pixel = Messages.pixel
        let stop: CGFloat = 112
        let half: CGFloat = 9 * pixel
        var buddyX: CGFloat = 240
        var buddyUp: CGFloat = half
        var step: Int?
        var buddyEyes = 0
        var buddyFacing = -1
        var buddyWave = false
        var caseAt: CGPoint?
        let clawdHand = point(10.8, 3.6)
        let clawdCase = CGPoint(x: clawdHand.x + 7, y: clawdHand.y - 12)
        switch t {
        case ..<0.6:
            right = .reach(0.3)
            look = 0.5
            eyes = .open
            caseAt = clawdCase
            place(Art.msgBriefcase, at: clawdCase, scale: 0.4 + 0.6 * Pose.ease(CGFloat(t / 0.3)))
        case ..<2.0:
            let p = Pose.msgStep(t, 0.6, 1.4)
            right = .reach(0.3)
            look = 0.5
            eyes = t > 1.6 ? .happy : .open
            buddyX = 240 - (240 - stop) * (1 - (1 - p) * (1 - p))
            step = p < 0.96 ? Int(t / 0.15) % 2 : nil
            buddyUp += step == 0 ? 2 : 0
            caseAt = clawdCase
        case ..<2.5:
            let k = CGFloat(sin(.pi * 2 * (t - 2.0) / 0.5))
            right = .reach(0.3)
            look = 0.5
            eyes = .happy
            bob = 0.15 * max(0, k)
            buddyX = stop
            buddyEyes = 1
            buddyUp -= 3 * max(0, -k)
            caseAt = clawdCase
        case ..<3.3:
            let p = Pose.ease(Pose.msgStep(t, 2.5, 0.8))
            right = .reach(0.3 + 0.3 * sin(.pi * p))
            dx = 3 * sin(.pi * p)
            look = 0.5
            eyes = .happy
            buddyX = stop
            buddyEyes = 1
            let target = CGPoint(x: stop - 38, y: half - 13)
            caseAt = Pose.msgArc(clawdCase, target, p, height: 8)
        case ..<4.0:
            let k = CGFloat(sin(.pi * 2 * (t - 3.3) / 0.35))
            look = 0.5
            eyes = .happy
            bob = 0.12 * max(0, k)
            buddyX = stop
            buddyEyes = 1
            buddyUp -= 2 * max(0, k)
            caseAt = CGPoint(x: stop - 38, y: half - 13)
            heart = CGFloat((t - 3.3) / 0.7)
        case ..<5.8:
            let p = Pose.msgStep(t, 4.0, 1.8)
            let wave = Int(clock / 0.18) % 2 == 0
            right = wave ? .up : .diagUp
            look = 0.5
            eyes = .happy
            buddyFacing = 1
            buddyX = stop + (250 - stop) * p * p
            step = p > 0.05 ? Int(t / 0.15) % 2 : nil
            buddyUp += step == 0 ? 2 : 0
            buddyWave = p > 0.15 && p < 0.55 && Int(clock / 0.2) % 2 == 0
            caseAt = CGPoint(x: buddyX - 38, y: buddyUp - 13)
        default:
            let p = Pose.msgStep(t, 5.8, 1.2)
            look = 0.5 * (1 - p)
            if p < 0.6 {
                eyes = .closed
                sy = 1 - 0.04 * sin(.pi * p / 0.6)
            } else {
                eyes = .happy
            }
            buddyX = 300
        }
        if buddyX < 230 {
            place(Art.msgBuddy(step: step, eyes: buddyEyes, facing: buddyFacing, armUp: buddyWave), buddyX, buddyUp)
        }
        if let caseAt, t >= 0.6 { place(Art.msgBriefcase, at: caseAt) }
    }

    mutating func limit(t: TimeInterval, clock: TimeInterval) {
        let pixel = Messages.pixel
        let fill = min(1, 0.15 + 0.85 * CGFloat(t / 2.0))
        let blink = fill >= 1 && Int(clock / 0.25) % 2 == 0
        let barFade = t > 6.1 ? max(0, 1 - (t - 6.1) / 0.5) : min(1, t / 0.25)
        let signHalf = 11.5 * pixel
        let planted = CGPoint(x: 64, y: signHalf)
        switch t {
        case ..<2.0:
            let phase = Int(t / 0.17) % 2
            legs = phase == 0 ? [0.45, 0, 0.45, 0] : [0, 0.45, 0, 0.45]
            bob = phase == 0 ? -0.15 : 0
            look = 0.4
            eyes = fill > 0.75 ? .focused : .open
            sweat = fill > 0.8
        case ..<2.35:
            let k = CGFloat(sin(.pi * (t - 2.0) / 0.35))
            legs = [0.45, 0, 0.45, 0]
            bob = -0.15
            eyes = .wide
            exclaim = true
            tilt = 5 * Double(k)
            lookY = -0.4
        case ..<2.6:
            eyes = .wide
            exclaim = true
            lookY = -0.4
            sweat = true
        case ..<3.2:
            let p = Pose.msgStep(t, 2.6, 0.6)
            right = .diagUp
            eyes = .focused
            sweat = true
            let hand = point(12, 0.4)
            let pop = Pose.ease(p * 2)
            place(Art.msgStop, hand.x + 2, hand.y + (signHalf - 4) * pop, opacity: Double(min(1, p * 4)), scale: 0.4 + 0.6 * pop)
        case ..<4.6:
            right = .diagUp
            eyes = .focused
            sweat = true
            look = t > 4.0 ? (Int((t - 4.0) / 0.15) % 2 == 0 ? -0.35 : 0.35) : 0
            let hand = point(12, 0.4)
            place(Art.msgStop, hand.x + 2 + 1.5 * CGFloat(sin(clock * 9)), hand.y + signHalf - 4)
        case ..<5.2:
            let p = Pose.ease(Pose.msgStep(t, 4.6, 0.6))
            right = p < 0.5 ? .diagUp : .reach(0.3)
            eyes = .open
            look = 0.4
            lookY = 0.2
            let hand = point(12, 0.4)
            let from = CGPoint(x: hand.x + 2, y: hand.y + signHalf - 4)
            place(Art.msgStop, at: Pose.msgArc(from, planted, p, height: 6))
            if t > 5.0 { dust = CGFloat((t - 5.0) / 0.4) }
        case ..<5.7:
            let p = Pose.msgStep(t, 5.2, 0.5)
            msgSit(1 - (1 - p) * (1 - p))
            eyes = .closed
            sweat = true
        case ..<6.4:
            msgSit(1)
            let beat = (t - 5.7) / 0.35
            left = .diagUp
            right = .diagUp
            eyes = .closed
            bob -= 0.15 * CGFloat(abs(sin(.pi * beat)))
            look = 0.2
        default:
            let p = Pose.msgStep(t, 6.4, 0.4)
            msgSit(1 - Pose.ease(p))
            eyes = .happy
        }
        if t >= 5.2 {
            place(Art.msgStop, at: planted, opacity: t > 6.3 ? max(0, 1 - (t - 6.3) / 0.5) : 1)
        }
        place(Pose.bar(fill, blink: blink), at: point(6, -4.6), opacity: barFade)
    }
}
