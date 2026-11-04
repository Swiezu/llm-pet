import AppKit
import SwiftUI

@main
struct LlmPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra("llm-pet", systemImage: "pawprint.fill") {
            PetMenu()
        }
    }
}

struct PetMenu: View {
    private let pet = Pet.shared
    @Bindable private var settings = AppSettings.shared

    var body: some View {
        Button(pet.enabled ? tr("Hide pet", "Schowaj peta") : tr("Show pet", "Pokaż peta")) { pet.toggle() }
        Button(tr("Settings…", "Ustawienia…")) { SettingsWindow.show() }
            .keyboardShortcut(",")
        Divider()
        Toggle(tr("Animations", "Animacje"), isOn: $settings.animationsEnabled)
        Toggle(tr("Fast mode", "Tryb szybki"), isOn: $settings.fastMode)
        Divider()
        Section(tr("Channels", "Kanały")) {
            ForEach($settings.channels) { $channel in
                Toggle(channel.name, isOn: Binding(get: { !channel.muted }, set: { channel.muted = !$0 }))
            }
        }
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
            Divider()
            Button(tr("Until closed, with a link", "Do zamknięcia, z linkiem")) {
                pet.say(DebugTexts.sticky(settings.lang), for: .infinity, link: URL(string: "https://github.com/Swiezu/llm-pet"))
            }
            Button(tr("10 s, with a folder link", "10 s, z linkiem do folderu")) {
                pet.say(DebugTexts.timedLink(settings.lang), for: 10, link: FileManager.default.homeDirectoryForCurrentUser.appending(path: "Downloads"))
            }
            Button(tr("With a title and subtitle", "Z nagłówkiem i podtytułem")) {
                pet.say(DebugTexts.timedLink(settings.lang), title: "CI", subtitle: "llm-pet · main", for: 10)
            }
            Button(tr("Conversation (left and right)", "Rozmowa (lewo i prawo)")) {
                pet.say(tr("Got a minute for a review?", "Masz chwilę na review?"), title: "Ala → Ola", subtitle: "12:01", style: .left, for: 12)
                pet.say(tr("Sure, send the link.", "Jasne, wrzuć link."), title: "Ola → Ala", subtitle: "12:02", style: .right, for: 12)
            }
            Button(tr("Long, 30 s (expand)", "Długi, 30 s (rozwiń)")) {
                pet.say(DebugTexts.long(settings.lang), for: 30)
            }
            Button(tr("Long, until closed (expand)", "Długi, do zamknięcia (rozwiń)")) {
                pet.say(DebugTexts.long(settings.lang), for: .infinity)
            }
            Button(tr("5 bubbles at once (queue)", "5 dymków naraz (kolejka)")) {
                for index in 1...5 { pet.say(tr("Bubble \(index) of 5", "Dymek \(index) z 5"), for: 4) }
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
    private var quitting = false

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

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard !quitting else { return .terminateNow }
        quitting = true
        Pet.shared.leave { Task { @MainActor in NSApp.reply(toApplicationShouldTerminate: true) } }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(10))
            NSApp.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    func applicationWillTerminate(_ notification: Notification) {
        Pet.shared.savePosition()
        PetServer.shared.stop()
    }
}
