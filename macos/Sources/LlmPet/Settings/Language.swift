import AppKit
import SwiftUI

enum Language: String, CaseIterable, Identifiable {
    case en, pl

    var id: String { rawValue }
    var name: String { self == .en ? "English" : "Polski" }
}

@MainActor
func tr(_ en: String, _ pl: String) -> String {
    AppSettings.shared.lang == .pl ? pl : en
}

@MainActor
enum LanguageWindow {
    private static var window: NSWindow?

    static func ask(then done: @escaping @MainActor () -> Void) {
        let window = NSWindow(contentViewController: NSHostingController(rootView: LanguagePicker { language in
            AppSettings.shared.language = language
            Self.window?.close()
            Self.window = nil
            done()
        }))
        window.title = "llm-pet"
        window.styleMask = [.titled]
        window.isReleasedWhenClosed = false
        window.center()
        Self.window = window
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }
}

private struct LanguagePicker: View {
    let choose: (Language) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose your language\nWybierz język")
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize()
            HStack(spacing: 12) {
                ForEach(Language.allCases) { language in
                    Button(language.name) { choose(language) }
                        .controlSize(.large)
                        .frame(minWidth: 110)
                }
            }
        }
        .padding(28)
        .frame(minWidth: 320)
    }
}
