import SwiftUI

struct PetView: View {
    let pet: Pet

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / Double(AppSettings.shared.fps))) { context in
            let now = context.date
            PetFrame(
                pose: Pose(pet: pet, now: now),
                action: pet.action,
                t: now.timeIntervalSince(pet.actionStart),
                clock: now.timeIntervalSinceReferenceDate,
                facing: pet.facing,
                grounded: !pet.held && !pet.falling
            )
            .onTapGesture { pet.poke() }
            .gesture(DragGesture(minimumDistance: 3).onChanged { _ in pet.hold() }.onEnded { _ in pet.release() })
            .help(tr("Click for a trick, drag to move, hide it from the paw in the menu bar", "Klik = sztuczka, przeciągnij = przenieś, chowasz łapką w pasku menu"))
        }
    }
}

struct PetFrame: View {
    let pose: Pose
    let action: Action
    let t: TimeInterval
    let clock: TimeInterval
    let facing: CGFloat
    let grounded: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Style.shadow.opacity(grounded && !pose.hidden ? 0.3 * (1 - min(pose.lift, 100) / 140) : 0))
                .frame(width: 78 * (1 - min(pose.lift, 100) / 250), height: 8)
                .blur(radius: 3)
                .offset(x: pose.dx * facing)
            if action == .teleport && grounded { PortalView(t: t, clock: clock) }
            ItemsView(items: pose.items.filter(\.behind), facing: facing)
            if pose.flames > 0 { FlameAuraView(intensity: pose.flames, dx: pose.dx * facing, lift: pose.lift, clock: clock) }
            if action == .party && grounded { ConfettiView(t: t) }
            if action == .sleep && grounded { SleepView(clock: clock) }
            SpriteView(pose: pose, t: t, clock: clock)
                .frame(width: Style.canvas.width * Style.unit, height: Style.canvas.height * Style.unit)
                .scaleEffect(x: facing * pose.sx * (pose.flip ? -1 : 1), y: pose.sy, anchor: .bottom)
                .rotationEffect(.degrees(pose.tilt * (pose.carried ? 1 : Double(facing))), anchor: pose.tiltAnchor)
                .offset(x: pose.dx * facing, y: -pose.lift + 0.5 * Style.unit)
                .opacity(pose.hidden ? 0 : 1)
                .contentShape(Rectangle().inset(by: 20).offset(x: pose.dx * facing, y: -pose.lift))
                .frame(width: Pet.size.width, height: Pet.size.height, alignment: .bottom)
                .mask(alignment: .leading) {
                    Rectangle().padding(.leading, pose.mask.map { Pet.size.width / 2 + $0 * facing } ?? 0)
                }
            if let flying = pose.flying { FlyingView(flying: flying, facing: facing) }
            ItemsView(items: pose.items.filter { !$0.behind }, facing: facing)
            if let beam = pose.beam { BeamView(beam: beam, facing: facing, clock: clock) }
            if let shockwave = pose.shockwave { ShockwaveView(progress: shockwave, dx: pose.dx * facing, lift: pose.lift) }
        }
        .frame(width: Pet.size.width, height: Pet.size.height, alignment: .bottom)
    }
}
