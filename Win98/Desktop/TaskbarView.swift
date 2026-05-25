import SwiftUI
import Combine

// MARK: - Taskbar
struct TaskbarView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var currentTime: String = Self.formattedTime()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 0) {
            // Start button
            StartButton()

            // Quick launch separator
            taskbarSeparator

            // Quick launch buttons
            QuickLaunchArea()

            taskbarSeparator

            // Window buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(windowManager.taskbarWindows) { win in
                        TaskbarWindowButton(windowState: win)
                    }
                }
                .padding(.horizontal, 2)
            }

            Spacer()

            taskbarSeparator

            // System tray
            SystemTrayView(currentTime: currentTime)
        }
        .frame(height: Win98Metrics.taskbarHeight)
        .background(Win98Color.taskbarBackground)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Win98Color.buttonHighlight),
            alignment: .top
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Win98Color.buttonShadow),
            alignment: .bottom
        )
        .onAppear { currentTime = Self.formattedTime() }
        .onReceive(timer) { _ in currentTime = Self.formattedTime() }
    }

    var taskbarSeparator: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Win98Color.buttonShadow)
                .frame(width: 1, height: Win98Metrics.taskbarHeight - 6)
            Rectangle()
                .fill(Win98Color.buttonHighlight)
                .frame(width: 1, height: Win98Metrics.taskbarHeight - 6)
        }
        .padding(.horizontal, 3)
    }

    static func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}

// MARK: - Start Button
struct StartButton: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var isPressed = false

    var body: some View {
        Button(action: { windowManager.toggleStartMenu() }) {
            HStack(spacing: 4) {
                WindowsLogoView(size: 14)
                Text("Start")
                    .font(Win98Font.bold(Win98Metrics.systemFontSize + 1))
                    .foregroundColor(Win98Color.darkText)
            }
            .padding(.horizontal, 6)
            .frame(width: Win98Metrics.startButtonWidth, height: Win98Metrics.taskbarHeight - 4)
            .background(Win98Color.buttonFace)
            .modifier(BevelModifier(style: windowManager.showStartMenu ? .sunken : .raised))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.leading, 2)
        .padding(.vertical, 2)
    }
}

// MARK: - Quick Launch Area
struct QuickLaunchArea: View {
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        HStack(spacing: 3) {
            QuickLaunchIcon(icon: ExplorerIcon(size: 18).eraseToAnyView(), tooltip: "Launch Internet Explorer") {
                windowManager.openApp(.myComputer, screenSize: windowManager.screenSize)
            }
            QuickLaunchIcon(icon: showDesktopIcon.eraseToAnyView(), tooltip: "Show Desktop") {
                // Minimize all windows
                for win in windowManager.windows {
                    win.isMinimized = true
                }
                windowManager.objectWillChange.send()
            }
        }
        .padding(.horizontal, 2)
    }

    var showDesktopIcon: some View {
        Canvas { ctx, sz in
            let s = sz.width / 18
            ctx.fill(Path(CGRect(x: 1*s, y: 4*s, width: 12*s, height: 10*s)), with: .color(.white))
            ctx.stroke(Path(CGRect(x: 1*s, y: 4*s, width: 12*s, height: 10*s)), with: .color(.black), lineWidth: s)
            ctx.fill(Path(CGRect(x: 4*s, y: 2*s, width: 8*s, height: 3*s)), with: .color(.init(hex: "#C0C0C0")))
        }
        .frame(width: 18, height: 18)
    }
}

struct QuickLaunchIcon: View {
    let icon: AnyView
    let tooltip: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            icon
                .padding(2)
                .background(isPressed ? Win98Color.buttonFace.opacity(0.5) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .help(tooltip)
    }
}

// MARK: - Taskbar Window Button
struct TaskbarWindowButton: View {
    @ObservedObject var windowState: Win98WindowState
    @EnvironmentObject var windowManager: WindowManager

    var isActive: Bool {
        windowManager.activeWindowID == windowState.id && !windowState.isMinimized
    }

    var body: some View {
        Button(action: {
            if windowState.isMinimized {
                windowState.isMinimized = false
                windowManager.bringToFront(windowState.id)
            } else if isActive {
                windowState.isMinimized = true
            } else {
                windowManager.bringToFront(windowState.id)
            }
            windowManager.objectWillChange.send()
        }) {
            HStack(spacing: 4) {
                Win98Icons.appIcon(for: windowState.app)
                    .frame(width: 14, height: 14)
                Text(windowState.title)
                    .font(Win98Font.small)
                    .foregroundColor(Win98Color.darkText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 6)
            .frame(width: 130, height: Win98Metrics.taskbarHeight - 6)
            .frame(maxWidth: 160)
            .background(Win98Color.buttonFace)
            .modifier(BevelModifier(style: isActive ? .sunken : .raised))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - System Tray
struct SystemTrayView: View {
    let currentTime: String

    var body: some View {
        HStack(spacing: 4) {
            // Volume icon
            Image(systemName: "speaker.wave.2")
                .font(.system(size: 12))
                .foregroundColor(Win98Color.darkText)

            // Time
            Text(currentTime)
                .font(Win98Font.small)
                .foregroundColor(Win98Color.darkText)
                .padding(.trailing, 4)
        }
        .padding(.horizontal, 6)
        .frame(height: Win98Metrics.taskbarHeight - 4)
        .background(Win98Color.buttonFace)
        .win98Well()
        .padding(.vertical, 3)
        .padding(.trailing, 3)
    }
}

// MARK: - AnyView helper
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
