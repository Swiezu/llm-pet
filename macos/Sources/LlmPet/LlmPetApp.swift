import AppKit
import SwiftUI

@main
struct LlmPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra("llm-pet", systemImage: "pawprint.fill") {
            MenuContent()
        }
    }
}

private struct MenuContent: View {
    private let pet = Pet.shared
    private let settings = AppSettings.shared

    var body: some View {
        Button(pet.enabled ? tr("Hide pet", "Schowaj peta") : tr("Show pet", "Pokaż peta")) { pet.toggle() }
        Button(tr("Settings…", "Ustawienia…")) { SettingsWindow.show() }
            .keyboardShortcut(",")
        Divider()
        Menu("DEBUG ANIMATION") {
            ForEach(Action.allCases) { action in
                Button(action.title(settings.lang)) { pet.perform(action) }
            }
        }
        .disabled(!pet.enabled)
        Menu("DEBUG TEXT") {
            ForEach(DebugTexts.all(settings.lang), id: \.self) { text in
                Button(DebugTexts.preview(text)) { pet.say(text) }
            }
        }
        .disabled(!pet.enabled)
        Menu("DEBUG CHANNEL") {
            ForEach(settings.channels) { channel in
                Button(channel.muted ? tr("\(channel.name) (muted)", "\(channel.name) (wyciszony)") : channel.name) {
                    pet.say(DebugTexts.all(settings.lang).randomElement() ?? DebugTexts.greeting(settings.lang), on: channel)
                }
            }
        }
        .disabled(!pet.enabled)
        Divider()
        Button(tr("Quit", "Zakończ")) { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let arguments = CommandLine.arguments
        if let index = arguments.firstIndex(of: "--dump-frames"), index + 1 < arguments.count {
            FrameDump.run(to: URL(fileURLWithPath: arguments[index + 1]))
            exit(0)
        }
        if let index = arguments.firstIndex(of: "--render-docs"), index + 1 < arguments.count {
            DocsRender.run(to: URL(fileURLWithPath: arguments[index + 1]))
            exit(0)
        }
        PetServer.shared.start()
        if AppSettings.shared.language == nil {
            LanguageWindow.ask { Pet.shared.restore() }
        } else {
            Pet.shared.restore()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        PetServer.shared.stop()
    }
}
