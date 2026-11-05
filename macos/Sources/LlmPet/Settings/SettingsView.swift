import AppKit
import SwiftUI

struct SettingsView: View {
    @Bindable var settings = AppSettings.shared

    var body: some View {
        Form {
            Section {
                ForEach($settings.channels) { $channel in
                    ChannelRow(channel: $channel)
                }
                Button(tr("Add channel", "Dodaj kanał"), systemImage: "plus") { settings.addChannel() }
            } header: {
                Text(tr("Channels", "Kanały"))
            } footer: {
                Text(tr("In the API a channel is addressed by name or id. Messages sent to a muted channel are not shown; channels are muted and unmuted only here, in the menu bar or in the right-click menu on the pet, never through the API.", "W API kanał wskazujesz nazwą albo identyfikatorem. Wiadomości na wyciszony kanał nie są pokazywane; wyciszysz i odciszysz go tylko tutaj, w pasku menu albo w menu pod prawym klikiem na pecie, nigdy przez API."))
                    .foregroundStyle(.secondary)
            }
            Section(tr("Language", "Język")) {
                Picker(tr("Language", "Język"), selection: Binding(get: { settings.lang }, set: { settings.language = $0 })) {
                    ForEach(Language.allCases) { Text($0.name).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Section(tr("Size", "Rozmiar")) {
                LabeledContent(tr("Pet size", "Rozmiar postaci")) {
                    HStack {
                        Slider(value: $settings.petScale, in: AppSettings.petScales, step: 0.05)
                        Text("\(Int((settings.petScale * 100).rounded())) %")
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                LabeledContent(tr("Bubble text", "Czcionka dymków")) {
                    HStack {
                        Slider(value: $settings.bubbleFont, in: AppSettings.bubbleFonts, step: 1)
                        Text("\(Int(settings.bubbleFont)) pt")
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                .onChange(of: settings.bubbleFont) {
                    if !Pet.shared.bubbles.speaking { Pet.shared.say(tr("This is how bubbles look", "Tak wyglądają dymki"), for: 3) }
                }
            }
            Section {
                LabeledContent(tr("Max bubble width", "Maksymalna szerokość dymku")) {
                    HStack {
                        Slider(value: $settings.bubbleWidth, in: AppSettings.bubbleWidths, step: 10)
                        Text("\(Int(settings.bubbleWidth)) pt")
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                LabeledContent(tr("Max bubble height", "Maksymalna wysokość dymku")) {
                    HStack {
                        Slider(value: Binding(get: { Double(settings.bubbleLines) }, set: { settings.bubbleLines = Int($0.rounded()) }), in: Double(AppSettings.bubbleHeights.lowerBound)...Double(AppSettings.bubbleHeights.upperBound), step: 1)
                        Text(tr("\(settings.bubbleLines) ln", "\(settings.bubbleLines) l."))
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                .onChange(of: settings.bubbleWidth) { preview() }
                .onChange(of: settings.bubbleLines) { preview() }
            } header: {
                Text(tr("Max bubble size", "Maksymalny rozmiar dymku"))
            } footer: {
                Text(tr("Width and height of a collapsed bubble. Longer messages get \"more\".", "Szerokość i wysokość zwiniętego dymku. Dłuższe wiadomości mają \"więcej\"."))
                    .foregroundStyle(.secondary)
            }
            Section {
                LabeledContent(tr("Max width", "Maksymalna szerokość")) {
                    HStack {
                        Slider(value: $settings.expandedWidth, in: AppSettings.expandedWidths, step: 20)
                        Text("\(Int(settings.expandedWidth)) pt")
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                LabeledContent(tr("Max height", "Maksymalna wysokość")) {
                    HStack {
                        Slider(value: Binding(get: { Double(settings.expandedLines) }, set: { settings.expandedLines = Int($0.rounded()) }), in: Double(AppSettings.expandedHeights.lowerBound)...Double(AppSettings.expandedHeights.upperBound), step: 1)
                        Text(tr("\(settings.expandedLines) ln", "\(settings.expandedLines) l."))
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
            } header: {
                Text(tr("Expanded bubble", "Rozwinięty dymek"))
            } footer: {
                Text(tr("\"More\" expands the bubble to the whole text, at most this size and the room on screen; anything longer scrolls. The countdown stops until you collapse it or close it with X.", "\"Więcej\" rozwija dymek do całego tekstu, najwyżej do tego rozmiaru i miejsca na ekranie; dłuższy tekst się przewija. Odliczanie stoi, dopóki go nie zwiniesz albo nie zamkniesz X."))
                    .foregroundStyle(.secondary)
            }
            Section {
                LabeledContent(tr("Animation speed", "Prędkość animacji")) {
                    HStack {
                        Slider(value: $settings.animationSpeed, in: AppSettings.speeds, step: 0.25)
                        Text(Self.multiplier(settings.animationSpeed))
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                LabeledContent(tr("Speed in fast mode", "Prędkość w trybie szybkim")) {
                    HStack {
                        Slider(value: $settings.fastSpeed, in: AppSettings.fastSpeeds, step: 0.25)
                        Text(Self.multiplier(settings.fastSpeed))
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                Toggle(tr("Fast mode", "Tryb szybki"), isOn: $settings.fastMode)
                Toggle(tr("Animations", "Animacje"), isOn: $settings.animationsEnabled)
                Picker(tr("FPS on power", "FPS na zasilaniu"), selection: Self.frames($settings.fpsPower)) {
                    ForEach(AppSettings.availableFPS, id: \.self) { Text($0 == AppSettings.vsyncFPS ? "VSync" : "\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
                Picker(tr("FPS on battery", "FPS na baterii"), selection: Self.frames($settings.fpsBattery)) {
                    ForEach(AppSettings.availableFPS, id: \.self) { Text($0 == AppSettings.vsyncFPS ? "VSync" : "\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
            } header: {
                Text(tr("Animation", "Animacja"))
            } footer: {
                Text(tr("Now: \(settings.onBattery ? "battery" : "power adapter"), \(settings.fps) FPS", "Teraz: \(settings.onBattery ? "bateria" : "zasilanie"), \(settings.fps) FPS"))
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 600)
        .frame(minHeight: 360)
    }

    private static func frames(_ value: Binding<Int>) -> Binding<Int> {
        Binding(get: { value.wrappedValue == AppSettings.vsyncFPS ? AppSettings.vsyncFPS : min(value.wrappedValue, AppSettings.displayFPS) }, set: { value.wrappedValue = $0 })
    }

    private static func multiplier(_ value: Double) -> String {
        String(format: "%.2g×", value)
    }

    private func preview() {
        if !Pet.shared.bubbles.speaking { Pet.shared.say(DebugTexts.long(settings.lang), for: 4) }
    }
}

private struct ChannelRow: View {
    @Binding var channel: Channel

    var body: some View {
        HStack(spacing: 10) {
            ColorPicker("Kolor", selection: Binding(get: { channel.background }, set: { channel.color = NSColor($0).hex }), supportsOpacity: false)
                .labelsHidden()
                .help(tr("Bubble color", "Kolor dymka"))
            ColorPicker(tr("Title", "Tytuł"), selection: Binding(get: { channel.heading }, set: { channel.headingColor = NSColor($0).hex }), supportsOpacity: false)
                .labelsHidden()
                .help(tr("Title color", "Kolor tytułu"))
            ColorPicker(tr("Accent", "Akcent"), selection: Binding(get: { channel.accent }, set: { channel.accentColor = NSColor($0).hex }), supportsOpacity: false)
                .labelsHidden()
                .help(tr("Subtitle and \"more\" color", "Kolor podtytułu i \"więcej\""))
            TextField(tr("Name", "Nazwa"), text: $channel.name, prompt: Text(tr("Name", "Nazwa")))
                .labelsHidden()
                .multilineTextAlignment(.leading)
                .textFieldStyle(.roundedBorder)
            Text(channel.isMain ? tr("main", "główny") : channel.id)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            (Text(tr("Title ", "Tytuł ")).foregroundStyle(channel.heading) + Text(tr("text ", "tekst ")).foregroundStyle(channel.foreground) + Text(tr("more", "więcej")).foregroundStyle(channel.accent))
                .font(.caption.weight(.semibold).monospaced())
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(channel.background, in: RoundedRectangle(cornerRadius: 3))
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(.black.opacity(0.8), lineWidth: 1.5))
            Toggle(isOn: $channel.muted) { Image(systemName: channel.muted ? "speaker.slash.fill" : "speaker.wave.2.fill") }
                .toggleStyle(.button)
                .help(channel.muted ? tr("Unmute channel", "Odcisz kanał") : tr("Mute channel", "Wycisz kanał"))
            Button(tr("Delete", "Usuń"), systemImage: "trash") { AppSettings.shared.removeChannel(channel.id) }
                .labelStyle(.iconOnly)
                .disabled(channel.isMain)
                .help(channel.isMain ? tr("The main channel cannot be deleted", "Głównego kanału nie można usunąć") : tr("Delete channel", "Usuń kanał"))
        }
    }
}
