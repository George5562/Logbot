import SwiftUI
import LogbotControl

@main
struct LogbotControlApp: App {
    var body: some Scene {
        WindowGroup {
            ControlView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
} 