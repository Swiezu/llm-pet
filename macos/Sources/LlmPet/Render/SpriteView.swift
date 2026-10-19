import SwiftUI

struct SpriteView: View {
    let pose: Pose
    let t: TimeInterval
    let clock: TimeInterval

    var body: some View {
        Canvas { context, _ in
            let u = Style.unit
            func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color) {
                context.fill(Path(CGRect(x: (Style.origin.x + x) * u, y: (Style.origin.y + y) * u, width: w * u, height: h * u)), with: .color(color))
            }
            func disc(_ x: CGFloat, _ y: CGFloat, _ d: CGFloat) {
                context.fill(Path(ellipseIn: CGRect(x: (Style.origin.x + x - d / 2) * u, y: (Style.origin.y + y - d / 2) * u, width: d * u, height: d * u)), with: .color(.black))
            }
            func loop(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat) {
                context.stroke(Path(ellipseIn: CGRect(x: (Style.origin.x + cx - w / 2) * u, y: (Style.origin.y + cy - h / 2) * u, width: w * u, height: h * u)), with: .color(Style.band), lineWidth: 0.38 * u)
            }
            func art(_ art: PixelArt, _ cx: CGFloat, _ cy: CGFloat, opacity: Double = 1, scale: CGFloat = 1) {
                art.draw(context, center: CGPoint(x: (Style.origin.x + cx) * u, y: (Style.origin.y + cy) * u), pixel: u / 2 * scale, opacity: opacity)
            }
            let b = pose.bob
            let left: CGFloat = 2
            let width: CGFloat = pose.narrow ? 7 : 8
            let right = left + width
            let middle = left + width / 2
            if pose.aura > 0 {
                let frame = Int(clock / 0.06)
                for (index, degrees) in [180.0, 207, 234, 261, 288, 315, 342, 0].enumerated() where (frame / 2 + index) % 3 != 0 {
                    let angle = degrees * .pi / 180
                    let start = 6.0 + 0.5 * CGFloat((frame + index) % 2)
                    for step in 0..<3 {
                        let r = start + 0.55 * CGFloat(step)
                        box(middle + 1.25 * r * CGFloat(cos(angle)) - 0.2, 3 + r * CGFloat(sin(angle)) + b - 0.2, 0.4, 0.4, Style.slate.opacity(Double(0.45 * pose.aura)))
                    }
                }
                let top: [CGFloat] = [left - 0.8, left + 1.8, middle - 0.25, right - 2.3, right + 0.3]
                let ring = top.map { ($0, CGFloat(-1.2), CGFloat(0), CGFloat(-1)) } + [1, 3.2, 5.4].flatMap { y in [(left - 1.3, CGFloat(y), CGFloat(-1), CGFloat(0)), (right + 0.8, CGFloat(y), CGFloat(1), CGFloat(0))] }
                for (index, point) in ring.enumerated() where (frame + index * 7) % 3 != 0 {
                    let push = 0.35 * CGFloat((frame + index) % 2)
                    let color = (index + frame) % 2 == 0 ? Style.light : Style.ivory
                    box(point.0 + point.2 * push, point.1 + point.3 * push + b, 0.5, 0.5, color.opacity(Double(pose.aura)))
                }
            }
            for (index, column) in (pose.narrow ? [2.0, 3.9, 6.1, 8.0] : [2.0, 4.0, 7.0, 9.0]).enumerated() {
                let length = pose.legLength - pose.legs[index]
                box(column, 6 + b, 1, length, Style.coral)
                box(column, 6 + b + length - 0.4, 1, 0.4, Style.shade)
            }
            box(left, b, width, 6, Style.coral)
            box(left, 5.5 + b, width, 0.5, Style.shade)
            box(left, b, 2, 0.5, Style.light)
            box(left, 0.5 + b, 0.5, 0.5, Style.light)
            if let keyboard = pose.keyboard {
                let x = left - 1.2 + keyboard.dx
                let y = 4.4 + b + keyboard.dy
                let pressed = keyboard.typing ? Int(clock / 0.055) * 7 % 11 : -1
                box(x, y, width + 2.4, 1.1, Style.keyboard)
                box(x, y, width + 2.4, 0.2, Style.keyboardRim)
                for row in 0..<2 {
                    for column in 0..<Int((width + 1.6) / 0.8) {
                        let key = row * 13 + column
                        box(x + 0.3 + CGFloat(column) * 0.8, y + 0.3 + CGFloat(row) * 0.4, 0.55, 0.25, key % 11 == pressed ? Style.coral : Style.keys)
                    }
                }
                if keyboard.typing {
                    for spark in 0..<3 {
                        let phase = clock / 0.3 + Double(spark) / 3
                        let p = CGFloat(phase.truncatingRemainder(dividingBy: 1))
                        let seed = Int(phase) * 5 + spark * 3
                        box(x + 0.6 + CGFloat(seed * 7 % 9), y - 0.3 - 1.4 * p, 0.3, 0.3, Style.keys.opacity(Double(1 - p)))
                    }
                }
            }
            switch pose.letter {
            case .envelope: art(Art.envelope, middle, 5.2 + b)
            case .opening(let p):
                if p > 0.45 { art(Art.page, middle, 5.2 + b - 1.4 * min(1, (p - 0.45) / 0.55)) }
                art(Art.envelopeOpen[p < 0.45 ? 0 : 1], middle, 5.4 + b)
            case .reading: art(Art.page, middle, 5.5 + b)
            case .raised, .none: break
            }
            switch pose.paper {
            case .sheet: art(Art.sheet, right - 0.4, 4.9 + b)
            case .folded(let step): art(Art.folds[min(step, Art.folds.count - 1)], right - 0.4, 4.9 + b)
            case .plane: art(Art.plane[0], right - 0.2, 4.8 + b)
            case .raised, .none: break
            }
            let flail: CGFloat = Int(clock * 8) % 2 == 0 ? 2 : 1
            let rightArm = pose.narrow && pose.right == .side ? Pose.Arm.hidden : pose.right
            for (isRight, arm) in [(false, pose.left), (true, rightArm)] {
                func part(_ o: CGFloat, _ w: CGFloat, _ y: CGFloat, _ h: CGFloat, _ color: Color = Style.coral) {
                    box(isRight ? right + o : left - o - w, y + b, w, h, color)
                }
                let outer = isRight ? right + 1.6 : left - 1.6
                switch arm {
                case .hidden:
                    if case .sides = pose.bells { disc(isRight ? right + 0.4 : left - 0.4, 4.6 + b, 1.5) }
                case .side:
                    part(0, 2, 3, 2)
                    part(0, 2, 4.5, 0.5, Style.shade)
                    if case .sides = pose.bells { disc(outer, 4.6 + b, 1.5) }
                case .up:
                    part(-1, 1, -1.5, 1.5)
                    if case .sides = pose.bells {
                        let x = isRight ? right - 1 : left
                        box(x - 0.8, -2.15 + b, 2.6, 0.35, .black)
                        disc(x - 0.8, -1.95 + b, 1.3)
                        disc(x + 1.8, -1.95 + b, 1.3)
                    }
                case .diagUp:
                    part(0, 1, 1.5, 2)
                    part(1, 1, 0.5, 2)
                    part(1, 1, 2, 0.5, Style.shade)
                case .diagDown:
                    part(0, 1, 3.5, 1.5)
                    part(1, 1, 4.5, 1.5)
                    part(1, 1, 5.5, 0.5, Style.shade)
                case .tucked:
                    part(0, 0.7, 3.2, 1.6)
                case .flail:
                    part(0, 2, 3 - flail, 2)
                    part(0, 2, 4.5 - flail, 0.5, Style.shade)
                case .reach(let up):
                    part(0, 1.2, 3.1 - up, 1.4)
                    part(0, 1.2, 4.3 - up, 0.2, Style.shade)
                case .chin:
                    part(0, 1, 2.8, 2.2)
                    part(0, 1, 4.8, 0.2, Style.shade)
                    box(isRight ? right - 1.9 : left + 0.9, 4.3 + b, 1.0, 0.8, Style.light)
                    box(isRight ? right - 1.9 : left + 0.9, 5.1 + b, 1.0, 0.2, Style.shade)
                }
            }
            if let dust = pose.dust, dust < 1 {
                for puff in 0..<3 {
                    let spread = 1 + CGFloat(puff) * 0.7 + 1.6 * dust
                    let size = 0.5 * (1 - dust) + 0.2
                    let lift = 0.4 * dust * CGFloat(puff + 1)
                    box(left - spread - size, 7 - lift - size, size, size, Style.dust.opacity(Double(1 - dust)))
                    box(right + spread, 7 - lift - size, size, size, Style.dust.opacity(Double(1 - dust)))
                }
            }
            if case .floor = pose.bells {
                disc(left - 1.2, 6.6, 1.5)
                disc(right + 1.2, 6.6, 1.5)
            }
            switch pose.band {
            case .none: break
            case .grab: box(left - 2.1, 5.2 + b, 1.1, 0.9, Style.band)
            case .grabUp: box(left - 2.1, -0.1 + b, 1.0, 0.9, Style.band)
            case .hand: loop(left - 2.3, 4.4 + b, 1.2, 1.8)
            case .hanging: loop(left - 1.6, 6.7 + b, 1.0, 1.5)
            case .raised: loop(left + 0.5, -2.7 + b, 1.3, 2.2)
            case .tilted(let lift):
                let center = CGPoint(x: (Style.origin.x + left + width / 2 + 0.3) * u, y: (Style.origin.y - 1 - lift + b) * u)
                let ellipse = Path(ellipseIn: CGRect(x: -width / 2 * u, y: -0.8 * u, width: width * u, height: 1.6 * u))
                context.stroke(ellipse.applying(CGAffineTransform(rotationAngle: -0.25).concatenating(CGAffineTransform(translationX: center.x, y: center.y))), with: .color(Style.band), lineWidth: 0.38 * u)
            case .line: box(left - 1.2, 0.55 + b, width + 2.4, 0.38, Style.band)
            case .head: box(left - 0.2, 0.55 + b, width + 0.4, 0.38, Style.band)
            }
            for (index, column) in (pose.narrow ? [2.7, 6.7] : [3.0, 8.0]).enumerated() {
                let x = column + pose.look
                let b = b + pose.lookY
                switch pose.eyes {
                case .wide:
                    box(x - 0.1, 2.1 + b, 1.25, 1.4, .black.opacity(0.9))
                    box(x + 0.1, 2.25 + b, 0.4, 0.4, .white.opacity(0.85))
                case .led:
                    let on = Int(clock / 0.25) % 4 != 0
                    box(x - 0.05, 2.3 + b, 1.15, 1.0, .black.opacity(0.85))
                    box(x + 0.15, 2.5 + b, 0.75, 0.6, on ? Style.led : Style.led.opacity(0.4))
                case .dizzy:
                    for (dx, dy) in [(0.0, 2.35), (0.75, 2.35), (0.375, 2.75), (0.0, 3.15), (0.75, 3.15)] {
                        box(x + dx, dy + b, 0.32, 0.32, .black)
                    }
                case .focused:
                    box(x, 2.8 + b, 1.05, 0.5, pose.ssj ? Style.ssjEye : .black.opacity(0.9))
                    if pose.ssj { box(x + (index == 0 ? 0.55 : 0.2), 2.85 + b, 0.3, 0.4, .black.opacity(0.85)) }
                    box(x + 0.15, 2.85 + b, 0.3, 0.22, .white.opacity(0.8))
                    let inner = index == 0 ? 0.5 : 0
                    box(x + inner, 2.42 + b, 0.55, 0.22, .black)
                    box(x + 0.5 - inner, 2.25 + b, 0.55, 0.22, .black)
                case .open:
                    box(x, 2.25 + b, 1.05, 1.18, .black.opacity(0.9))
                    box(x + 0.15, 2.4 + b, 0.35, 0.35, .white.opacity(0.75))
                case .blink: box(x, 2.95 + b, 1.05, 0.3, .black)
                case .closed: box(x, 2.85 + b, 1.05, 0.55, .black.opacity(0.8))
                case .happy:
                    box(x, 2.9 + b, 0.36, 0.36, .black)
                    box(x + 0.34, 2.55 + b, 0.36, 0.36, .black)
                    box(x + 0.68, 2.9 + b, 0.36, 0.36, .black)
                }
            }
            if let p = pose.rubble {
                for stone in 0..<6 {
                    let phase = CGFloat((clock / 1.1 + Double(stone) / 6).truncatingRemainder(dividingBy: 1))
                    let x = [-2.6, -1.2, 0.4, 8.6, 10.4, 11.6][stone]
                    let rise = (2.5 + CGFloat(stone % 3)) * phase * p
                    box(CGFloat(x) + 0.3 * CGFloat(sin(Double(phase) * 9)), 6.8 - rise, 0.45, 0.4, Style.slate.opacity(Double(0.75 * (1 - phase))))
                }
            }
            switch pose.cup {
            case .back:
                box(left - 0.5, 3.1 + b, 0.8, 1.6, Style.coral)
                box(left - 2.3, 2.9 + b, 1.9, 2.0, Style.coral)
                box(left - 2.3, 4.7 + b, 1.9, 0.2, Style.shade)
                box(left - 2.1, 3.7 + b, 1.5, 0.4, Style.shade)
            case .front:
                box(right, 2.7 + b, 2.2, 0.9, Style.coral)
                box(right, 3.9 + b, 2.2, 0.9, Style.coral)
                box(right, 4.6 + b, 2.2, 0.2, Style.shade)
                box(right + 2.2, 2.4 + b, 0.7, 2.6, Style.light)
            case nil: break
            }
            if let radius = pose.charge {
                let center = pose.cup == .front ? CGPoint(x: right + 3.4, y: 3.7 + b) : CGPoint(x: left - 2.9, y: 3.9 + b)
                let pixel: CGFloat = 0.5
                let pulse = radius * (1 + 0.1 * CGFloat(sin(clock * 40)))
                let cells = Int(ceil(pulse / pixel))
                for gy in -cells...cells {
                    for gx in -cells...cells {
                        let x = (CGFloat(gx) + 0.5) * pixel
                        let y = (CGFloat(gy) + 0.5) * pixel
                        let r = sqrt(x * x + y * y) / pulse
                        guard r <= 1 else { continue }
                        let band = r > 0.8 ? 0 : r > 0.55 ? 1 : r > 0.3 ? 2 : 3
                        box(center.x + CGFloat(gx) * pixel, center.y + CGFloat(gy) * pixel, pixel, pixel, Style.ki[band].opacity(band == 0 ? 0.75 : 1))
                    }
                }
                if pose.cup == .back {
                    for mote in 0..<8 {
                        let phase = CGFloat((clock / 0.5 + Double(mote) / 8).truncatingRemainder(dividingBy: 1))
                        let angle = Double(mote) * .pi / 4 + 0.4
                        let distance = radius + 3.2 * (1 - phase)
                        box(center.x + distance * CGFloat(cos(angle)) - 0.2, center.y + 0.8 * distance * CGFloat(sin(angle)) - 0.2, 0.4, 0.4, Style.ki[2].opacity(Double(phase)))
                    }
                }
            }
            if pose.hair > 0 {
                let spikes: [(CGFloat, CGFloat)] = [(left - 0.3, 1.5), (left + 1.3, 2.4), (middle - 0.7, 3.1), (right - 2.7, 2.5), (right - 1.1, 1.7)]
                for (x, height) in spikes {
                    let rows = Int(height * pose.hair * 2)
                    guard rows > 0 else { continue }
                    let lean = (x + 0.7 - middle) / 5
                    for row in 0..<rows {
                        let w = max(0.5, 1.6 * (1 - CGFloat(row) / CGFloat(rows)))
                        let cx = x + 0.8 + lean * CGFloat(row) * 0.5
                        box(cx - w / 2 - 0.2, b - 0.5 * CGFloat(row + 1) - 0.2, w + 0.4, 0.7, Style.hairLine)
                    }
                    for row in 0..<rows {
                        let k = CGFloat(row) / CGFloat(rows)
                        let w = max(0.5, 1.6 * (1 - k))
                        let cx = x + 0.8 + lean * CGFloat(row) * 0.5
                        box(cx - w / 2, b - 0.5 * CGFloat(row + 1), w, 0.5, Style.gold[row % 3 == 2 ? 0 : 1])
                        box(cx - w / 2, b - 0.5 * CGFloat(row + 1), min(w, 0.5), 0.5, Style.gold[2])
                    }
                }
                box(left, b, width, 0.5, Style.gold[0])
            }
            if pose.sparks {
                let frame = Int(clock / 0.07)
                for bolt in 0..<3 where (frame * 7 + bolt * 5) % 3 != 0 {
                    let seed = frame * 13 + bolt * 29
                    let angle = Double(seed % 360) * .pi / 180
                    var point = CGPoint(x: middle + 5.2 * CGFloat(cos(angle)), y: 3 + 4.2 * CGFloat(sin(angle)) + b)
                    for step in 0..<5 {
                        box(point.x, point.y, 0.4, 0.4, step % 2 == 0 ? .white : Style.ki[2])
                        point.x += 0.4 * CGFloat(cos(angle)) + (step % 2 == 0 ? 0.4 : -0.4) * CGFloat(sin(angle))
                        point.y += 0.4 * CGFloat(sin(angle)) - (step % 2 == 0 ? 0.4 : -0.4) * CGFloat(cos(angle))
                    }
                }
            }
            if pose.sweat {
                let p = CGFloat((clock / 0.8).truncatingRemainder(dividingBy: 1))
                box(right - 0.6, 0.6 + 2.2 * p + b, 0.45, 0.6, Style.water.opacity(Double(1 - p)))
                box(right - 0.5, 0.4 + 2.2 * p + b, 0.25, 0.25, Style.water.opacity(Double(1 - p)))
            }
            if pose.exclaim { art(Art.exclaim, right + 1.3, -2.3 + b) }
            for dot in 0..<min(pose.thought, 3) {
                let size = 0.5 + 0.2 * CGFloat(dot)
                let x = right + 0.3 + 1.1 * CGFloat(dot)
                let y = -0.6 - 1.1 * CGFloat(dot) + b
                box(x - 0.1, y - 0.1, size + 0.2, size + 0.2, .black.opacity(0.7))
                box(x, y, size, size, Style.ivory)
            }
            if let p = pose.bulb {
                let pop = min(1, p * 4)
                let scale = pop < 1 ? 0.5 + 0.7 * pop : 1 + 0.08 * CGFloat(sin(clock * 10))
                art(Art.bulb, middle, -3.4 + b, scale: scale)
                if p > 0.25 {
                    let ray = Int(clock / 0.15) % 2 == 0 ? 0.0 : 0.3
                    box(middle - 0.25, -6.3 - ray + b, 0.5, 0.6, Style.bulb)
                    box(middle - 2.9 - ray, -3.65 + b, 0.6, 0.5, Style.bulb)
                    box(middle + 2.3 + ray, -3.65 + b, 0.6, 0.5, Style.bulb)
                    box(middle - 2.3 - ray, -5.4 - ray + b, 0.5, 0.5, Style.bulb)
                    box(middle + 1.8 + ray, -5.4 - ray + b, 0.5, 0.5, Style.bulb)
                }
            }
            if let p = pose.heart { art(Art.heart, right + 0.8, -2.2 - 1.6 * p + b, opacity: Double(1 - p * p)) }
            if pose.stars {
                for star in 0..<3 {
                    let angle = clock * 5 + Double(star) * 2 * .pi / 3
                    art(Art.star, middle + 4.6 * CGFloat(cos(angle)), -0.7 + 0.8 * CGFloat(sin(angle)) + b, opacity: sin(angle) > -0.3 ? 1 : 0.55)
                }
            }
            if pose.notes {
                for note in 0..<2 {
                    let p = CGFloat((clock / 1.6 + Double(note) / 2).truncatingRemainder(dividingBy: 1))
                    art(Art.note, right + 0.9 + 0.7 * CGFloat(sin(Double(p) * 6)), -0.6 - 4.2 * p + b, opacity: Double(sin(.pi * p)))
                }
            }
            if pose.steam {
                for puff in 0..<3 {
                    let p = CGFloat((clock / 0.9 + Double(puff) / 3).truncatingRemainder(dividingBy: 1))
                    let size = 0.5 + 0.5 * p
                    box(middle + CGFloat(puff - 1) * 2.2 + 0.4 * CGFloat(sin(Double(p) * 7)) - size / 2, -0.4 - 3.4 * p + b, size, size, Style.ivory.opacity(Double(0.85 * (1 - p))))
                }
            }
            if let p = pose.pebble, p < 1 {
                let hop = p < 0.7 ? 2.4 * sin(.pi * p / 0.7) : 0.7 * sin(.pi * (p - 0.7) / 0.3)
                box(right + 0.6 + 5.5 * p, 6.6 - hop, 0.7, 0.6, Style.slate.opacity(0.8))
                box(right + 0.75 + 5.5 * p, 6.6 - hop, 0.25, 0.2, Style.dust)
            }
            if case .raised = pose.letter { art(Art.envelope, right - 0.5, -3.25 + b) }
            if case .raised = pose.paper { art(Art.plane[1], right - 0.2, -2.9 + b) }
            if pose.flag {
                let pole = right - 0.65
                box(pole, -6.6 + b, 0.3, 5.15, .black)
                let swing = CGFloat(cos(t * 6.5))
                let cell = 0.5 * max(0.18, abs(swing))
                for column in 0..<8 {
                    let wave = 0.3 * sin(t * 11 - Double(column) * 0.8)
                    let x = swing >= 0 ? pole + 0.3 + CGFloat(column) * cell : pole - CGFloat(column + 1) * cell
                    box(x, -6.6 + wave + b, cell, 3, .white)
                    for row in 0..<6 where (row + column) % 2 == 0 {
                        box(x, -6.6 + CGFloat(row) * 0.5 + wave + b, cell, 0.5, .black)
                    }
                }
            }
        }
    }
}
