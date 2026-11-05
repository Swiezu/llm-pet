import AppKit
import SwiftUI

@MainActor
enum SettingsWindow {
    private static var window: NSWindow?

    static func show() {
        let window = window ?? {
            let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView()))
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.center()
            Self.window = window
            return window
        }()
        retitle()
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    static func retitle() {
        window?.title = tr("llm-pet Settings", "Ustawienia llm-pet")
    }
}
