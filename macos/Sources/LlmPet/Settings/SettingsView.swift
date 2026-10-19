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
                Text(tr("In the API a channel is addressed by name or id. Messages sent to a muted channel are not shown; channels can be muted and unmuted only here.", "W API kanał wskazujesz nazwą albo identyfikatorem. Wiadomości na wyciszony kanał nie są pokazywane; wyciszyć i odciszyć można tylko tutaj."))
                    .foregroundStyle(.secondary)
            }
            Section(tr("Language", "Język")) {
                Picker(tr("Language", "Język"), selection: Binding(get: { settings.lang }, set: { settings.language = $0 })) {
                    ForEach(Language.allCases) { Text($0.name).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Section(tr("Animation", "Animacja")) {
                Picker(tr("Frames per second", "Klatki na sekundę"), selection: $settings.fps) {
                    ForEach(AppSettings.fpsOptions, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
        .formStyle(.grouped)
        .frame(width: 520)
        .frame(minHeight: 360)
    }
}

private struct ChannelRow: View {
    @Binding var channel: Channel

    var body: some View {
        HStack(spacing: 10) {
            ColorPicker("Kolor", selection: Binding(get: { channel.background }, set: { channel.color = NSColor($0).hex }), supportsOpacity: false)
                .labelsHidden()
            TextField(tr("Name", "Nazwa"), text: $channel.name, prompt: Text(tr("Name", "Nazwa")))
                .labelsHidden()
                .multilineTextAlignment(.leading)
                .textFieldStyle(.roundedBorder)
            Text(channel.isMain ? tr("main", "główny") : channel.id)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            Text(tr("Preview", "Przykład"))
                .font(.caption.weight(.semibold).monospaced())
                .foregroundStyle(channel.foreground)
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
