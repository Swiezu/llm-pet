import Foundation

extension Pose {
    public init(action: Action, t: TimeInterval, clock: TimeInterval, walked: CGFloat = 0) {
        self.init()
        if clock.truncatingRemainder(dividingBy: Idle.blink.every) < Idle.blink.length { eyes = .blink }
        switch action {
        case .walk: walk(walked: walked)
        case .idle: idle(clock: clock)
        case .hop: hop(t: t)
        case .flag: flag(t: t)
        case .party: party(t: t)
        case .workout: workout(t: t)
        case .sleep: sleep(clock: clock)
        case .teleport: teleport(t: t, clock: clock)
        case .typing: typing(t: t, clock: clock)
        case .dillyDally: dillyDally(t: t, clock: clock)
        case .lockIn: lockIn(t: t, clock: clock)
        case .letter: letter(t: t, clock: clock)
        case .paperPlane: paperPlane(t: t, clock: clock)
        case .kamehameha: kamehameha(t: t, clock: clock)
        case .powerUp: powerUp(t: t, clock: clock)
        case .coffee: coffee(t: t, clock: clock)
        case .buffering: buffering(t: t, clock: clock)
        case .deploy: deploy(t: t, clock: clock)
        case .contextFull: contextFull(t: t, clock: clock)
        case .compact: contextCompact(t: t, clock: clock)
        case .helloAI: helloAI(t: t, clock: clock)
        case .shipIt: shipIt(t: t, clock: clock)
        case .smoke: smoke(t: t, clock: clock)
        case .chill: chill(t: t, clock: clock)
        case .lunch: lunch(t: t, clock: clock)
        case .mute: mute(t: t, clock: clock)
        case .unmute: unmute(t: t, clock: clock)
        case .beamDown: beamDown(t: t, clock: clock)
        case .poofIn: poofIn(t: t, clock: clock)
        case .flyIn: flyIn(t: t, clock: clock)
        case .portalOut: portalOut(t: t, clock: clock)
        case .beamUp: beamUp(t: t, clock: clock)
        case .poof: poof(t: t, clock: clock)
        case .flyAway: flyAway(t: t, clock: clock)
        }
    }
}
