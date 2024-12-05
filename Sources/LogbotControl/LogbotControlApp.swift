import SwiftUI

@main
public struct LogbotControlApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            ControlView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
} 