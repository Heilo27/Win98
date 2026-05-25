import SwiftUI

struct ContentView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var booted: Bool = false

    var body: some View {
        ZStack {
            if booted {
                DesktopView()
                    .environmentObject(windowManager)
                    .ignoresSafeArea()
                    .transition(.opacity)
            } else {
                BootScreenView {
                    withAnimation(.easeIn(duration: 0.3)) {
                        booted = true
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
        .animation(.easeIn(duration: 0.3), value: booted)
    }
}

#Preview {
    ContentView()
        .environmentObject(WindowManager())
}
