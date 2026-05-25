import SwiftUI

@main
struct Win98App: App {
    @StateObject private var windowManager = WindowManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(windowManager)
                .preferredColorScheme(.light)
        }
    }
}
