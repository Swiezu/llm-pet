import Foundation

extension Pose {
    init(action: Action, t: TimeInterval, clock: TimeInterval, walked: CGFloat = 0) {
        self.init()
        if clock.truncatingRemainder(dividingBy: 3.6) < 0.12 { eyes = .blink }
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
        }
    }

    @MainActor
    init(pet: Pet, now: Date) {
        let clock = now.timeIntervalSinceReferenceDate
        if pet.held || pet.falling {
            self.init()
            carry(held: pet.held, clock: clock)
        } else if let landed = pet.landStart, now.timeIntervalSince(landed) < 0.3 {
            self.init()
            land(now.timeIntervalSince(landed))
        } else if now < pet.resizeUntil {
            self.init()
            resize(growing: pet.growing, clock: clock)
        } else {
            self.init(action: pet.action, t: now.timeIntervalSince(pet.actionStart), clock: clock, walked: pet.walked)
        }
    }
}
