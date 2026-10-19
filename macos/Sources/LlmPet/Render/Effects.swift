import SwiftUI

struct ConfettiView: View {
    let t: TimeInterval

    var body: some View {
        Canvas { context, size in
            let period = 1.25
            let burst = Int(t / period)
            for k in max(0, burst - 1)...burst {
                let age = t - Double(k) * period
                guard age >= 0, age < 2.2 else { continue }
                var seed = UInt64(k + 1) &* 6_364_136_223_846_793_005
                func random() -> Double {
                    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
                    return Double(seed >> 33) / Double(1 << 31)
                }
                let originX = size.width / 2 + (k % 2 == 0 ? -26 : 26)
                for _ in 0..<16 {
                    let vx = (random() - 0.5) * 120
                    let vy = -(110 + random() * 90)
                    let color = Style.confetti[Int(random() * 3) % 3]
                    let spin = random() * 6
                    let x = originX + vx * age
                    let y = size.height - 85 + vy * age + 130 * age * age
                    let flat = Int(spin + age * 6) % 2 == 0
                    context.fill(Path(CGRect(x: x, y: y, width: flat ? 6 : 3, height: flat ? 3 : 6)), with: .color(color.opacity(max(0, 1 - age / 2.2))))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct SleepView: View {
    let clock: TimeInterval

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                let p = (clock / 2.4 + Double(index) / 3).truncatingRemainder(dividingBy: 1)
                Text("z")
                    .font(.system(size: 12 + 8 * p, weight: .heavy, design: .rounded))
                    .foregroundStyle(Style.coral.opacity(sin(.pi * p) * 0.9))
                    .offset(x: 18 + 14 * p + 4 * sin(6 * p), y: -60 - 70 * p)
            }
        }
        .allowsHitTesting(false)
    }
}

struct PortalView: View {
    let t: TimeInterval
    let clock: TimeInterval

    var body: some View {
        Canvas { context, size in
            guard let portal = Teleport.portal(t) else { return }
            let pixel = Style.unit / 2
            let center = CGPoint(x: size.width / 2 + Teleport.portalX, y: size.height - Teleport.portalUp)
            let a = Teleport.radius.width * portal.ring
            let b = Teleport.radius.height * portal.ring
            if portal.ring > 0.05 {
                let columns = Int(ceil(a / pixel)) + 1
                let rows = Int(ceil(b / pixel)) + 1
                for gy in -rows...rows {
                    for gx in -columns...columns {
                        let x = (CGFloat(gx) + 0.5) * pixel
                        let y = (CGFloat(gy) + 0.5) * pixel
                        let r = sqrt(pow(x / a, 2) + pow(y / b, 2))
                        guard r <= 1 else { continue }
                        let angle = atan2(Double(y), Double(x))
                        let swirl = sin(4 * angle - clock * 5 + Double(r) * 5) > 0.5
                        let color: Color = switch r {
                        case 0.88...: Style.shade
                        case 0.7...: swirl ? Style.kraft : Style.book
                        case 0.45...: swirl ? Style.ivory : Style.manilla
                        default: Style.ivory
                        }
                        context.fill(Path(CGRect(x: center.x + CGFloat(gx) * pixel, y: center.y + CGFloat(gy) * pixel, width: pixel, height: pixel)), with: .color(color.opacity(portal.opacity)))
                    }
                }
                for mote in 0..<5 {
                    let angle = clock * 2.2 + Double(mote) * 2 * .pi / 5
                    let point = CGPoint(x: center.x + (a + pixel) * CGFloat(cos(angle)), y: center.y + (b + pixel) * CGFloat(sin(angle)))
                    let snapped = CGPoint(x: (point.x / pixel).rounded() * pixel, y: (point.y / pixel).rounded() * pixel)
                    context.fill(Path(CGRect(origin: snapped, size: CGSize(width: pixel, height: pixel))), with: .color((mote % 2 == 0 ? Style.light : Style.kraft).opacity(portal.opacity)))
                }
            }
            if portal.spark > 0 {
                Art.spark[Int(clock / 0.09) % 2].draw(context, center: center, pixel: pixel * max(0.5, portal.spark), opacity: portal.opacity)
            }
        }
        .allowsHitTesting(false)
    }
}

struct FlyingView: View {
    let flying: Pose.Flying
    let facing: CGFloat

    var body: some View {
        Canvas { context, size in
            let pixel = Style.unit / 2
            let place = { (point: CGPoint) in CGPoint(x: size.width / 2 + point.x * facing, y: size.height - point.y) }
            for (index, point) in flying.trail.enumerated() {
                let spot = place(point)
                let snapped = CGRect(x: (spot.x / pixel).rounded() * pixel, y: (spot.y / pixel).rounded() * pixel, width: pixel * 0.8, height: pixel * 0.8)
                context.fill(Path(snapped), with: .color(Style.paperLine.opacity(flying.opacity * (1 - Double(index) / 4.5))))
            }
            let art: PixelArt = switch flying.kind {
            case .envelope: flying.frame == 0 ? Art.envelope : Art.envelopeTilted
            case .plane: Art.plane[flying.frame]
            }
            var mirrored = context
            let center = place(CGPoint(x: flying.x, y: flying.up))
            if facing < 0 {
                mirrored.translateBy(x: center.x * 2, y: 0)
                mirrored.scaleBy(x: -1, y: 1)
            }
            art.draw(mirrored, center: center, pixel: pixel, opacity: flying.opacity)
        }
        .allowsHitTesting(false)
    }
}

struct BeamView: View {
    let beam: Pose.Beam
    let facing: CGFloat
    let clock: TimeInterval

    var body: some View {
        Canvas { context, size in
            let pixel = Style.unit / 2
            let start = CGPoint(x: size.width / 2 + Kamehameha.hands.x * facing, y: size.height - Kamehameha.hands.y)
            let reach = (size.width / 2 - Kamehameha.hands.x) * beam.length
            let half = 19 * beam.thickness * beam.power
            guard half > 3 else { return }
            func cell(_ x: CGFloat, _ y: CGFloat, _ color: Color) {
                let px = start.x + facing * x - (facing < 0 ? pixel : 0)
                context.fill(Path(CGRect(x: (px / pixel).rounded() * pixel, y: ((start.y + y) / pixel).rounded() * pixel, width: pixel, height: pixel)), with: .color(color))
            }
            let columns = Int(reach / pixel)
            for column in 0...max(0, columns) {
                let x = CGFloat(column) * pixel
                let wave = 1 + 0.14 * CGFloat(sin(Double(x) * 0.16 - clock * 34))
                let edge = half * wave
                let fade = Double(min(1, max(0, (reach - x) / 28)))
                let rows = Int(edge / pixel)
                for row in -rows...rows {
                    let r = abs(CGFloat(row) * pixel) / max(edge, 1)
                    let band = r > 0.78 ? 0 : r > 0.52 ? 1 : r > 0.26 ? 2 : 3
                    cell(x, CGFloat(row) * pixel, Style.ki[band].opacity((band == 0 ? 0.7 : 1) * fade))
                }
            }
            let flare = Int((half * 1.45 + 2 * CGFloat(sin(clock * 50))) / pixel)
            for gy in -flare...flare {
                for gx in -flare...flare {
                    let r = sqrt(CGFloat(gx * gx + gy * gy)) / CGFloat(max(flare, 1))
                    guard r <= 1 else { continue }
                    cell(CGFloat(gx) * pixel, CGFloat(gy) * pixel, Style.ki[r > 0.75 ? 1 : r > 0.4 ? 2 : 3])
                }
            }
            for streak in 0..<(beam.thickness > 0.4 ? 12 : 0) {
                let x = CGFloat((clock * 520 + Double(streak) * 41).truncatingRemainder(dividingBy: Double(max(reach, 1))))
                let y = CGFloat((streak * 37) % 9 - 4) * half / 5
                for step in 0..<3 { cell(x - CGFloat(step) * pixel, y, .white.opacity(0.9)) }
            }
            if let flash = beam.flash {
                let ring = (6 + 60 * flash) / pixel
                for index in 0..<24 {
                    let angle = Double(index) / 24 * 2 * .pi
                    cell(ring * pixel * CGFloat(cos(angle)), ring * pixel * CGFloat(sin(angle)), Style.ki[2].opacity(Double(1 - flash)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct FlameAuraView: View {
    let intensity: CGFloat
    let dx: CGFloat
    let lift: CGFloat
    let clock: TimeInterval

    var body: some View {
        Canvas { context, size in
            let pixel = Style.unit / 2
            let feet = CGPoint(x: size.width / 2 + dx, y: size.height - lift)
            let columns = 18
            for gx in -columns...columns {
                let side = CGFloat(abs(gx)) / CGFloat(columns)
                let flicker = 0.5 + 0.5 * sin(Double(gx) * 1.3 + clock * 16) + 0.35 * sin(Double(gx) * 0.7 - clock * 9)
                let top = (60 + intensity * (34 + 26 * CGFloat(flicker))) * (1 - 0.5 * side * side)
                let rows = Int(top / pixel)
                let bottom = Int(7 * side * side * side)
                for row in bottom...max(bottom, rows) {
                    let edge = min(rows - row, columns - abs(gx), row - bottom + (abs(gx) > columns - 4 ? 0 : 4))
                    let color: Color = switch edge {
                    case ..<1: (Int(clock / 0.05) + gx) % 3 == 0 ? .white : Style.gold[2]
                    case ..<2: Style.gold[1]
                    case ..<4: Style.gold[0].opacity(0.85)
                    default: Style.gold[1].opacity(0.1)
                    }
                    context.fill(Path(CGRect(x: feet.x + CGFloat(gx) * pixel - pixel / 2, y: feet.y - CGFloat(row + 1) * pixel, width: pixel, height: pixel)), with: .color(color.opacity(Double(min(1, intensity * 1.4)))))
                }
            }
            for ember in 0..<10 {
                let phase = CGFloat((clock * 1.6 + Double(ember) * 0.37).truncatingRemainder(dividingBy: 1))
                let x = feet.x + CGFloat((ember * 37) % 33 - 16) * pixel
                let y = feet.y - 60 - intensity * 40 - 50 * phase
                context.fill(Path(CGRect(x: (x / pixel).rounded() * pixel, y: (y / pixel).rounded() * pixel, width: pixel, height: pixel)), with: .color(Style.gold[ember % 3].opacity(Double(intensity * (1 - phase)))))
            }
        }
        .allowsHitTesting(false)
    }
}

struct ShockwaveView: View {
    let progress: CGFloat
    let dx: CGFloat
    let lift: CGFloat

    var body: some View {
        Canvas { context, size in
            guard progress < 1 else { return }
            let pixel = Style.unit / 2
            let center = CGPoint(x: size.width / 2 + dx, y: size.height - lift - 32)
            let fade = Double(1 - progress)
            let flash = 24 + 30 * progress
            let cells = Int(flash / pixel)
            for gy in -cells...cells {
                for gx in -cells...cells where CGFloat(gx * gx + gy * gy) * pixel * pixel <= flash * flash {
                    context.fill(Path(CGRect(x: center.x + CGFloat(gx) * pixel, y: center.y + CGFloat(gy) * pixel, width: pixel, height: pixel)), with: .color(.white.opacity(0.75 * fade * fade)))
                }
            }
            let radius = 20 + 190 * progress
            let steps = Int(radius * 2 * .pi / pixel)
            for step in 0..<max(1, steps) {
                let angle = Double(step) / Double(max(1, steps)) * 2 * .pi
                for thickness in 0..<2 {
                    let r = radius - CGFloat(thickness) * pixel
                    let x = ((center.x + r * CGFloat(cos(angle))) / pixel).rounded() * pixel
                    let y = ((center.y + 0.45 * r * CGFloat(sin(angle))) / pixel).rounded() * pixel
                    context.fill(Path(CGRect(x: x, y: y, width: pixel, height: pixel)), with: .color((thickness == 0 ? Style.gold[2] : Style.gold[0]).opacity(fade)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ItemsView: View {
    let items: [Pose.Item]
    let facing: CGFloat

    var body: some View {
        Canvas { context, size in
            let pixel = Style.unit / 2
            for item in items {
                let center = CGPoint(x: size.width / 2 + item.x * facing, y: size.height - item.up)
                var layer = context
                if facing < 0 {
                    layer.translateBy(x: center.x * 2, y: 0)
                    layer.scaleBy(x: -1, y: 1)
                }
                item.art.draw(layer, center: center, pixel: pixel * item.scale, opacity: item.opacity)
            }
        }
        .allowsHitTesting(false)
    }
}
