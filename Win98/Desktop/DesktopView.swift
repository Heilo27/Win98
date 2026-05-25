import SwiftUI

// MARK: - Desktop View (root)
struct DesktopView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var showContextMenu: Bool = false
    @State private var contextMenuPosition: CGPoint = .zero
    @State private var screenSize: CGSize = .zero

    let desktopApps: [Win98AppType] = [
        .myComputer, .myDocuments, .internetExplorer, .networkNeighborhood, .recycleBin
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Teal desktop background
                Win98Color.desktop
                    .ignoresSafeArea()

                // Dynamic Island / notch safe bars — covers top (portrait) and leading (landscape)
                // In landscape on iPhone Pro the DI is on the left; in portrait it's at the top
                Group {
                    if geo.safeAreaInsets.top > 0 {
                        VStack(spacing: 0) {
                            Color.black
                                .frame(height: geo.safeAreaInsets.top)
                                .ignoresSafeArea(edges: .top)
                            Spacer()
                        }
                    }
                    if geo.safeAreaInsets.leading > 0 {
                        HStack(spacing: 0) {
                            Color.black
                                .frame(width: geo.safeAreaInsets.leading)
                                .ignoresSafeArea(edges: .leading)
                            Spacer()
                        }
                    }
                }
                .zIndex(501)

                // Desktop icons — evenly spaced in available height above taskbar,
                // offset by leading safe area to clear Dynamic Island in landscape
                let leadingOffset = geo.safeAreaInsets.leading + 8
                let availableH = geo.size.height - Win98Metrics.taskbarHeight - 10
                let iconStep = min(80, availableH / CGFloat(desktopApps.count))
                ForEach(Array(desktopApps.enumerated()), id: \.element) { idx, app in
                    DesktopIcon(app: app) {
                        windowManager.openApp(app, screenSize: geo.size)
                    }
                    .position(
                        x: Win98Metrics.iconTouchSize / 2 + leadingOffset,
                        y: Win98Metrics.iconTouchSize / 2 + 8 + CGFloat(idx) * iconStep
                    )
                }

                // Windows (sorted by z-index)
                let sortedWindows = windowManager.windows
                    .filter { !$0.isMinimized }
                    .sorted { $0.zIndex < $1.zIndex }

                ForEach(sortedWindows) { win in
                    windowView(for: win, screenSize: geo.size)
                        .zIndex(Double(win.zIndex))
                        .onTapGesture {
                            windowManager.bringToFront(win.id)
                        }
                }

                // Context menu overlay
                if showContextMenu {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture { showContextMenu = false }
                        .zIndex(999)

                    DesktopContextMenu {
                        showContextMenu = false
                    }
                    .position(contextMenuPosition)
                    .zIndex(1000)
                }

                // Start Menu overlay
                if windowManager.showStartMenu {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture { windowManager.showStartMenu = false }
                        .zIndex(998)

                    let menuHeight: CGFloat = 400
                    let menuX = geo.safeAreaInsets.leading + Win98Metrics.startButtonWidth / 2 + 2
                    let menuYIdeal = geo.size.height - Win98Metrics.taskbarHeight - menuHeight / 2
                    let menuY = max(menuHeight / 2 + 4, menuYIdeal)
                    StartMenuView()
                        .position(x: menuX, y: menuY)
                        .zIndex(999)
                }

                // Shut Down dialog
                if windowManager.showShutDownDialog {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .zIndex(1001)
                    ShutDownDialog()
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .zIndex(1002)
                }

                // Taskbar
                VStack(spacing: 0) {
                    Spacer()
                    TaskbarView()
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(500)
            }
            .onAppear {
                screenSize = geo.size
                windowManager.screenSize = geo.size
            }
            .onChange(of: geo.size) { newSize in
                screenSize = newSize
                windowManager.screenSize = newSize
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.6)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag):
                            if let loc = drag?.startLocation {
                                contextMenuPosition = loc
                                showContextMenu = true
                            }
                        default: break
                        }
                    }
            )
        }
    }

    @ViewBuilder
    func windowView(for win: Win98WindowState, screenSize: CGSize) -> some View {
        Win98Window(windowState: win, screenSize: screenSize) {
            AnyView(windowContent(for: win))
        }
    }

    func windowContent(for win: Win98WindowState) -> some View {
        Group {
            switch win.app {
            case .myComputer:
                MyComputerView()
            case .myDocuments:
                MyDocumentsView()
            case .notepad:
                NotepadView(windowID: win.id)
            case .calculator:
                CalculatorView()
            case .minesweeper:
                MinesweeperView()
            case .solitaire:
                SolitaireView()
            case .recycleBin:
                RecycleBinView()
            case .networkNeighborhood:
                NetworkNeighborhoodView()
            case .explorer:
                WindowsExplorerView()
            case .internetExplorer:
                InternetExplorerView()
            case .shutDown:
                // shutDown is never opened as a real window (handled in WindowManager.openApp)
                Text("Not implemented")
                    .foregroundColor(Win98Color.darkText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Win98Color.windowBackground)
            }
        }
    }
}

// MARK: - Desktop Context Menu
struct DesktopContextMenu: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            contextItem("Arrange Icons") {}
            contextItem("Refresh") {}
            Divider().background(Win98Color.buttonShadow)
            contextItem("Paste") {}
            contextItem("Paste Shortcut") {}
            Divider().background(Win98Color.buttonShadow)
            contextItem("New") {}
            Divider().background(Win98Color.buttonShadow)
            contextItem("Properties") {}
        }
        .background(Win98Color.buttonFace)
        .win98Raised()
        .fixedSize()
    }

    @ViewBuilder
    func contextItem(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            onDismiss()
        }) {
            Text(title)
                .font(Win98Font.menu)
                .foregroundColor(Win98Color.darkText)
                .padding(.horizontal, 20)
                .frame(height: Win98Metrics.menuItemHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shut Down Dialog
struct ShutDownDialog: View {
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Image(systemName: "power")
                    .font(.system(size: 12))
                    .foregroundColor(Win98Color.titleText)
                Text("Shut Down Windows")
                    .font(Win98Font.title)
                    .foregroundColor(Win98Color.titleText)
                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(height: Win98Metrics.titleBarHeight)
            .background(
                LinearGradient(colors: [Win98Color.activeTitleLeft, Win98Color.activeTitleRight],
                               startPoint: .leading, endPoint: .trailing)
            )

            // Content
            HStack(spacing: 16) {
                Image(systemName: "power")
                    .font(.system(size: 40))
                    .foregroundColor(Win98Color.darkText)
                    .padding(8)

                VStack(alignment: .leading, spacing: 12) {
                    Text("What do you want the computer to do?")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.darkText)

                    HStack {
                        Image(systemName: "power")
                            .foregroundColor(Win98Color.darkText)
                        Text("Shut down")
                            .font(Win98Font.ui)
                            .foregroundColor(Win98Color.darkText)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Win98Color.selectionBackground)
                    .foregroundColor(Win98Color.titleText)
                }
            }
            .padding(16)
            .background(Win98Color.windowBackground)

            // Buttons
            HStack {
                Spacer()
                Win98Button(title: "OK") {
                    windowManager.showShutDownDialog = false
                }
                Win98Button(title: "Cancel") {
                    windowManager.showShutDownDialog = false
                }
                Win98Button(title: "Help") {}
            }
            .padding(8)
            .background(Win98Color.buttonFace)
        }
        .frame(width: 320)
        .win98Raised()
        .background(Win98Color.buttonFace)
    }
}

// MARK: - Placeholder Views
struct MyDocumentsView: View {
    var body: some View {
        VStack(spacing: 0) {
            Win98MenuBar(items: [
                ("File", [
                    Win98MenuBarItem("Close") {},
                ]),
                ("View", [
                    Win98MenuBarItem("Large Icons") {},
                    Win98MenuBarItem("Small Icons") {},
                ]),
            ])
            HStack {
                Text("My Documents folder is empty.")
                    .font(Win98Font.ui)
                    .foregroundColor(Win98Color.darkText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Win98Color.windowBackground)
        }
    }
}

struct NetworkNeighborhoodView: View {
    var body: some View {
        VStack(spacing: 0) {
            Win98MenuBar(items: [
                ("File", [Win98MenuBarItem("Close") {}]),
                ("View", [Win98MenuBarItem("Refresh") {}]),
            ])
            VStack {
                NetworkNeighborhoodIcon(size: 48)
                Text("No computers found in your workgroup.")
                    .font(Win98Font.ui)
                    .foregroundColor(Win98Color.darkText)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Win98Color.windowBackground)
        }
    }
}

struct WindowsExplorerView: View {
    var body: some View {
        VStack(spacing: 0) {
            Win98MenuBar(items: [
                ("File", [Win98MenuBarItem("Close") {}]),
                ("View", [Win98MenuBarItem("Refresh") {}]),
            ])
            HStack(spacing: 0) {
                // Left pane (tree)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Desktop")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.titleText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Win98Color.selectionBackground)
                    Text("  My Computer")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.darkText)
                        .padding(.horizontal, 8)
                    Spacer()
                }
                .frame(width: 160)
                .background(Win98Color.windowBackground)
                .win98Well()

                // Right pane (files)
                VStack {
                    Text("Select a folder to view its contents.")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.darkText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Win98Color.windowBackground)
            }
        }
    }
}

struct RecycleBinView: View {
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        VStack(spacing: 0) {
            Win98MenuBar(items: [
                ("File", [
                    Win98MenuBarItem("Empty Recycle Bin", isEnabled: windowManager.recycleHasFull) {
                        windowManager.recycleHasFull = false
                    },
                    Win98MenuBarItem("Close") {},
                ]),
                ("View", [Win98MenuBarItem("Refresh") {}]),
            ])

            if windowManager.recycleHasFull {
                VStack {
                    RecycleBinIcon(isFull: true, size: 48)
                    Text("Recycle Bin contains deleted files.")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.darkText)
                    Win98Button(title: "Empty Recycle Bin") {
                        windowManager.recycleHasFull = false
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Win98Color.windowBackground)
            } else {
                VStack {
                    RecycleBinIcon(isFull: false, size: 48)
                    Text("Recycle Bin is empty.")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.darkText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Win98Color.windowBackground)
            }
        }
    }
}
