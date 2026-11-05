import LlmPetRender

extension Action {
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
        case .smoke: ("Smoke break", "Palenie petka")
        case .chill: ("Chill", "Chillout")
        case .lunch: ("Lunch break", "Przerwa na szamę")
        case .mute: ("Muted", "Wyciszenie")
        case .unmute: ("Unmuted", "Odciszenie")
        case .beamDown: ("Beam down", "Słup światła (wejście)")
        case .poofIn: ("Poof in", "Puf! (wejście)")
        case .flyIn: ("Fly in", "Przylot ptaszkiem")
        case .portalOut: ("Into the portal", "Skok w portal")
        case .beamUp: ("Beam up", "Słup światła (wyjście)")
        case .poof: ("Poof", "Puf! (ulotnienie się)")
        case .flyAway: ("Fly away", "Odlot ptaszkiem")
        }
        return language == .pl ? pl : en
    }
}

extension Action.Category {
    func title(_ language: Language) -> String {
        let (en, pl): (String, String) = switch self {
        case .basics: ("Basics", "Podstawowe")
        case .entrance: ("Entrances", "Wejścia")
        case .exit: ("Exits", "Wyjścia")
        case .work: ("Work", "Praca")
        case .delivery: ("Delivery", "Wysyłka i wdrożenia")
        case .power: ("Power", "Moc")
        case .breaks: ("Breaks", "Przerwy")
        case .channels: ("Channels", "Kanały")
        }
        return language == .pl ? pl : en
    }
}
