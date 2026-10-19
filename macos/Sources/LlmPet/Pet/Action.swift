import Foundation

enum Action: String, CaseIterable, Identifiable {
    case idle, walk, hop, flag, party, workout, sleep, teleport, typing
    case dillyDally = "dillydally", lockIn = "lockin", letter, paperPlane = "plane", kamehameha, powerUp = "powerup"
    case coffee, buffering, deploy, contextFull = "contextfull", compact, helloAI = "helloai", shipIt = "shipit"

    static let tricks: [Action] = [.hop, .flag, .party]

    var id: String { rawValue }

    func title(_ language: Language) -> String {
        let (en, pl): (String, String) = switch self {
        case .idle: ("Idle", "Stanie")
        case .walk: ("Walk", "Spacer")
        case .hop: ("Hops", "Skoki")
        case .flag: ("Flag", "Flaga")
        case .party: ("Party", "Impreza")
        case .workout: ("Workout", "Trening")
        case .sleep: ("Sleep", "Sen")
        case .teleport: ("Teleport", "Teleport")
        case .typing: ("Typing", "Pisanie na klawiaturze")
        case .dillyDally: ("Dilly-dallying", "Dilly-dallying")
        case .lockIn: ("Lock in", "Lock in (głębokie myślenie)")
        case .letter: ("Letter", "Liścik")
        case .paperPlane: ("Paper plane", "Samolocik")
        case .kamehameha: ("Kamehameha", "Kamehameha")
        case .powerUp: ("Power up", "Transformacja")
        case .coffee: ("Coffee", "Kawa")
        case .buffering: ("Buffering", "Buffering")
        case .deploy: ("Deploy to prod", "Deploy na produkcję")
        case .contextFull: ("Context full", "Pełny kontekst")
        case .compact: ("Compact", "Compact kontekstu")
        case .helloAI: ("Hello fellow AI", "Hello fellow AI")
        case .shipIt: ("Ship it!", "Ship it!")
        }
        return language == .pl ? pl : en
    }

    var duration: TimeInterval {
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
        }
    }
}
