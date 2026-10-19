import AppKit
import SwiftUI

@MainActor
enum SettingsWindow {
    private static var window: NSWindow?

    static func show() {
        let window = window ?? {
            let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView()))
            window.title = tr("llm-pet Settings", "Ustawienia llm-pet")
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.center()
            Self.window = window
            return window
        }()
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }
}
