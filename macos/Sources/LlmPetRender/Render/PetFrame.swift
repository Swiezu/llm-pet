import SwiftUI

public struct PetFrame: View {
    public static let size = CGSize(width: 360, height: 320)

    let pose: Pose
    let action: Action
    let t: TimeInterval
    let clock: TimeInterval
    let facing: CGFloat
    let grounded: Bool

    public init(pose: Pose, action: Action, t: TimeInterval, clock: TimeInterval, facing: CGFloat, grounded: Bool) {
        self.pose = pose
        self.action = action
        self.t = t
        self.clock = clock
        self.facing = facing
        self.grounded = grounded
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Style.shadow.opacity(grounded && !pose.hidden ? 0.3 * (1 - min(pose.lift, 100) / 140) : 0))
                .frame(width: 78 * (1 - min(pose.lift, 100) / 250), height: 8)
                .blur(radius: 3)
                .offset(x: pose.dx * facing)
            if let portal = pose.portal, grounded { PortalView(portal: portal, clock: clock) }
            if let pillar = pose.pillar { PillarView(pillar: pillar, dx: pose.dx * facing, clock: clock) }
            ItemsView(items: pose.items.filter(\.behind), facing: facing)
            if pose.flames > 0 { FlameAuraView(intensity: pose.flames, dx: pose.dx * facing, lift: pose.lift, clock: clock) }
            if action == .party && grounded { ConfettiView(t: t) }
            if action == .sleep && grounded { SleepView(clock: clock) }
            SpriteView(pose: pose, t: t, clock: clock)
                .frame(width: Style.canvas.width * Style.unit, height: Style.canvas.height * Style.unit)
                .brightness(pose.glow)
                .scaleEffect(x: facing * pose.sx * (pose.flip ? -1 : 1), y: pose.sy, anchor: .bottom)
                .rotationEffect(.degrees(pose.tilt * (pose.carried ? 1 : Double(facing))), anchor: pose.tiltAnchor)
                .offset(x: pose.dx * facing, y: -pose.lift + 0.5 * Style.unit)
                .opacity(pose.hidden ? 0 : 1)
                .contentShape(Rectangle().inset(by: 20).offset(x: pose.dx * facing, y: -pose.lift))
                .frame(width: Self.size.width, height: Self.size.height, alignment: .bottom)
                .mask(alignment: .leading) {
                    Rectangle().padding(.leading, pose.mask.map { Self.size.width / 2 + $0 * facing } ?? 0)
                }
                .mask {
                    if let amount = pose.dissolve { DissolveMask(amount: amount, dx: pose.dx * facing, lift: pose.lift) } else { Rectangle() }
                }
            if let flying = pose.flying { FlyingView(flying: flying, facing: facing) }
            ItemsView(items: pose.items.filter { !$0.behind }, facing: facing)
            if let beam = pose.beam { BeamView(beam: beam, facing: facing, clock: clock) }
            if let shockwave = pose.shockwave { ShockwaveView(progress: shockwave, dx: pose.dx * facing, lift: pose.lift) }
            if let pillar = pose.pillar { PillarView(pillar: pillar, dx: pose.dx * facing, clock: clock, front: true) }
            if let cloud = pose.cloud { CloudView(cloud: cloud, facing: facing) }
        }
        .frame(width: Self.size.width, height: Self.size.height, alignment: .bottom)
    }
}
