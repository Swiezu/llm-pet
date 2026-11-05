import Foundation

public enum Action: String, CaseIterable, Identifiable, Sendable {
    case idle, walk, hop, flag, party, workout, sleep, teleport, typing
    case dillyDally = "dillydally", lockIn = "lockin", letter, paperPlane = "plane", kamehameha, powerUp = "powerup"
    case coffee, buffering, deploy, contextFull = "contextfull", compact, helloAI = "helloai", shipIt = "shipit"
    case smoke, chill, lunch, mute, unmute
    case beamDown = "beamdown", poofIn = "poofin", flyIn = "flyin"
    case portalOut = "portalout", beamUp = "beamup", poof, flyAway = "flyaway"

    public enum Category: String, CaseIterable, Identifiable, Sendable {
        case basics, entrance, exit, work, delivery, power, breaks, channels

        public var id: String { rawValue }
        public var actions: [Action] { Action.allCases.filter { $0.category == self } }
    }

    public static let tricks: [Action] = [.hop, .flag, .party]
    public static let entrances = Category.entrance.actions
    public static let exits = Category.exit.actions

    public var id: String { rawValue }

    public var category: Category {
        switch self {
        case .idle, .walk, .hop, .flag, .party, .sleep: .basics
        case .teleport, .beamDown, .poofIn, .flyIn: .entrance
        case .portalOut, .beamUp, .poof, .flyAway: .exit
        case .typing, .lockIn, .buffering, .contextFull, .compact, .helloAI: .work
        case .letter, .paperPlane, .deploy, .shipIt: .delivery
        case .workout, .kamehameha, .powerUp: .power
        case .coffee, .smoke, .chill, .lunch, .dillyDally: .breaks
        case .mute, .unmute: .channels
        }
    }

    public var duration: TimeInterval {
        switch self {
        case .idle: .infinity
        case .walk: 120
        case .hop: Hop.duration * 3
        case .flag: 4.5
        case .party: 4.8
        case .workout: Workout.duration
        case .sleep: 12
        case .teleport: Teleport.duration
        case .typing: Typing.duration
        case .dillyDally: DillyDally.duration
        case .lockIn: LockIn.duration
        case .letter: Mail.duration
        case .paperPlane: PaperPlane.duration
        case .kamehameha: Kamehameha.duration
        case .powerUp: PowerUp.duration
        case .coffee: Coffee.duration
        case .buffering: Buffering.duration
        case .deploy: Deploy.duration
        case .contextFull: Context.fullDuration
        case .compact: Context.compactDuration
        case .helloAI: HelloAI.duration
        case .shipIt: ShipIt.duration
        case .smoke: Smoke.duration
        case .chill: Smoke.chillDuration
        case .lunch: Lunch.duration
        case .mute, .unmute: Mute.duration
        case .beamDown: Beaming.downDuration
        case .poofIn: Poof.inDuration
        case .flyIn: Bird.inDuration
        case .portalOut: Teleport.outDuration
        case .beamUp: Beaming.upDuration
        case .poof: Poof.outDuration
        case .flyAway: Bird.awayDuration
        }
    }
}
