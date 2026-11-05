import Foundation
import Observation

enum DebugTexts {
    enum Sample: String, CaseIterable, Identifiable {
        case short, sentence, lines, word, long

        var id: String { rawValue }

        func title(_ language: Language) -> String {
            let (en, pl): (String, String) = switch self {
            case .short: ("Short", "Krótki")
            case .sentence: ("Sentence", "Zdanie")
            case .lines: ("Five lines", "Pięć linii")
            case .word: ("Word without spaces", "Słowo bez spacji")
            case .long: ("Long (expand)", "Długi (rozwiń)")
            }
            return language == .pl ? pl : en
        }

        func text(_ language: Language) -> String {
            let pl = language == .pl
            return switch self {
            case .short: pl ? "Build zielony ✅" : "Build is green ✅"
            case .sentence: pl ? "Potrzebuję decyzji: wdrażamy teraz czy po review? Opis zmian i lista ryzyk są gotowe, a pipeline jest zielony." : "Need a decision: ship now or after review? The change summary and risk list are ready, and the pipeline is green."
            case .lines: pl ? "Pora na przerwę.\nDruga linia.\nTrzecia linia.\nCzwarta linia.\nPiąta linia już się nie zmieści" : "Time for a break.\nSecond line.\nThird line.\nFourth line.\nFifth line will not fit"
            case .word: pl ? "Supercalifragilisticexpialidocious_bardzo_dlugie_slowo_bez_spacji_ktore_musi_sie_jakos_zawinac_123456789" : "Supercalifragilisticexpialidocious_a_very_long_word_without_spaces_that_has_to_wrap_somehow_123456789"
            case .long: DebugTexts.long(language)
            }
        }
    }

    static func greeting(_ language: Language) -> String {
        language == .pl ? "Cześć! 👋" : "Hi! 👋"
    }

    static func long(_ language: Language) -> String {
        String(repeating: language == .pl ? "Gargantuiczna wiadomość testowa, która musi się zawinąć i uciąć. " : "A gargantuan test message that has to wrap and get truncated. ", count: 30)
    }
}

@MainActor
@Observable
final class DebugBubble {
    static let shared = DebugBubble()

    enum Time: String, CaseIterable, Identifiable {
        case auto, tenSeconds, untilClosed

        var id: String { rawValue }

        var seconds: TimeInterval? {
            switch self {
            case .auto: nil
            case .tenSeconds: 10
            case .untilClosed: .infinity
            }
        }

        func title(_ language: Language) -> String {
            let (en, pl): (String, String) = switch self {
            case .auto: ("By length", "Wg długości")
            case .tenSeconds: ("10 s", "10 s")
            case .untilClosed: ("Until closed", "Do zamknięcia")
            }
            return language == .pl ? pl : en
        }
    }

    enum Link: String, CaseIterable, Identifiable {
        case none, web, folder

        var id: String { rawValue }

        var url: URL? {
            switch self {
            case .none: nil
            case .web: URL(string: "https://github.com/Swiezu/llm-pet")
            case .folder: FileManager.default.homeDirectoryForCurrentUser.appending(path: "Downloads")
            }
        }

        func title(_ language: Language) -> String {
            let (en, pl): (String, String) = switch self {
            case .none: ("None", "Brak")
            case .web: ("Website", "Strona")
            case .folder: ("Folder", "Folder")
            }
            return language == .pl ? pl : en
        }
    }

    var header = false
    var trick = false
    var time = Time.auto
    var link = Link.none
    var style = BubbleStyle.bubble
    var channelID = Channel.mainID

    static func title(_ style: BubbleStyle) -> String {
        switch style {
        case .bubble: tr("Bubble", "Dymek")
        case .left: tr("Chat, left", "Czat, lewo")
        case .right: tr("Chat, right", "Czat, prawo")
        }
    }

    private var channel: Channel {
        AppSettings.shared.channels.first { $0.id == channelID } ?? AppSettings.shared.main
    }

    func say(_ text: String, title: String? = nil, subtitle: String? = nil, style: BubbleStyle? = nil, for seconds: TimeInterval? = nil) {
        Pet.shared.say(
            text,
            title: title ?? (header ? "CI" : nil),
            subtitle: subtitle ?? (header ? "llm-pet · main" : nil),
            style: style ?? self.style,
            for: time.seconds ?? seconds,
            link: link.url,
            animation: trick ? Action.tricks.randomElement() : nil,
            on: channel
        )
    }

    func conversation() {
        say(tr("Got a minute for a review?", "Masz chwilę na review?"), title: "Ala → Ola", subtitle: "12:01", style: .left, for: 12)
        say(tr("Sure, send the link.", "Jasne, wrzuć link."), title: "Ola → Ala", subtitle: "12:02", style: .right, for: 12)
    }

    func queue() {
        for index in 1...12 { say(tr("Bubble \(index) of 12", "Dymek \(index) z 12"), for: 4) }
    }
}
