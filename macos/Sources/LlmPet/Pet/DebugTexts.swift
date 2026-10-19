enum DebugTexts {
    static func greeting(_ language: Language) -> String {
        language == .pl ? "Cześć! 👋" : "Hi! 👋"
    }

    static func all(_ language: Language) -> [String] {
        let pl = language == .pl
        return [
            greeting(language),
            pl ? "Test dymka" : "Bubble test",
            pl ? "Hej, tu Claude 👋" : "Hey, Claude here 👋",
            pl ? "Build zielony ✅" : "Build is green ✅",
            pl ? "Zadanie skończone: 12 plików zmienionych, wszystkie testy przechodzą." : "Task done: 12 files changed, all tests passing.",
            pl ? "Pora na przerwę.\nDruga linia.\nTrzecia linia.\nCzwarta linia.\nPiąta linia już się nie zmieści" : "Time for a break.\nSecond line.\nThird line.\nFourth line.\nFifth line will not fit",
            pl ? "Potrzebuję decyzji: wdrażamy teraz czy po review? Opis zmian i lista ryzyk są gotowe, a pipeline jest zielony." : "Need a decision: ship now or after review? The change summary and risk list are ready, and the pipeline is green.",
            pl ? "Supercalifragilisticexpialidocious_bardzo_dlugie_slowo_bez_spacji_ktore_musi_sie_jakos_zawinac_123456789" : "Supercalifragilisticexpialidocious_a_very_long_word_without_spaces_that_has_to_wrap_somehow_123456789",
            String(repeating: pl ? "Gargantuiczna wiadomość testowa, która musi się zawinąć i uciąć. " : "A gargantuan test message that has to wrap and get truncated. ", count: 30),
        ]
    }

    static func preview(_ text: String) -> String {
        let line = text.replacingOccurrences(of: "\n", with: " ")
        return line.count > 48 ? String(line.prefix(47)) + "…" : line
    }
}
