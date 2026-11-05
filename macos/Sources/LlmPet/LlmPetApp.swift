import AppKit
import LlmPetRender
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
    @Bindable private var debug = DebugBubble.shared

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
            ForEach(Action.Category.allCases) { category in
                Menu(category.title(settings.lang)) {
                    ForEach(category.actions) { action in
                        Button(action.title(settings.lang)) { pet.perform(action) }
                    }
                }
            }
        }
        .disabled(!pet.enabled)
        Menu("DEBUG TEXT") {
            ForEach(DebugTexts.Sample.allCases) { sample in
                Button(sample.title(settings.lang)) { debug.say(sample.text(settings.lang)) }
            }
            Divider()
            Button(tr("Conversation (left and right)", "Rozmowa (lewo i prawo)")) { debug.conversation() }
            Button(tr("12 bubbles at once (queue)", "12 dymków naraz (kolejka)")) { debug.queue() }
            Section(tr("Options", "Opcje")) {
                Toggle(tr("Title and subtitle", "Nagłówek i podtytuł"), isOn: $debug.header)
                Toggle(tr("Random trick", "Losowy trik"), isOn: $debug.trick)
                Picker(tr("Time", "Czas"), selection: $debug.time) {
                    ForEach(DebugBubble.Time.allCases) { Text($0.title(settings.lang)).tag($0) }
                }
                Picker(tr("Link", "Link"), selection: $debug.link) {
                    ForEach(DebugBubble.Link.allCases) { Text($0.title(settings.lang)).tag($0) }
                }
                Picker(tr("Style", "Styl"), selection: $debug.style) {
                    ForEach(BubbleStyle.allCases, id: \.self) { Text(DebugBubble.title($0)).tag($0) }
                }
                Picker(tr("Channel", "Kanał"), selection: $debug.channelID) {
                    ForEach(settings.channels) { channel in
                        Text(channel.muted ? tr("\(channel.name) (muted)", "\(channel.name) (wyciszony)") : channel.name).tag(channel.id)
                    }
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
