import SwiftUI

// MARK: - Window Chrome
struct Win98Window<Content: View>: View {
    @ObservedObject var windowState: Win98WindowState
    @EnvironmentObject var windowManager: WindowManager
    let content: Content
    let screenSize: CGSize

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @GestureState private var resizeDrag: CGSize = .zero
    @State private var isResizing: Bool = false
    @State private var resizeStartSize: CGSize = .zero
    @State private var resizeStartPos: CGPoint = .zero

    var isActive: Bool {
        windowManager.activeWindowID == windowState.id
    }

    init(windowState: Win98WindowState, screenSize: CGSize, @ViewBuilder content: () -> Content) {
        self.windowState = windowState
        self.screenSize = screenSize
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Window border background
            Rectangle()
                .fill(Win98Color.buttonFace)
                .frame(width: windowState.size.width, height: windowState.size.height)
                .win98Raised()

            VStack(spacing: 0) {
                // Title bar
                titleBar
                // Menu area (content provides its own menus via slots)
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: windowState.size.width, height: windowState.size.height)

            // Resize handle (bottom-right)
            if !windowState.isMaximized {
                resizeHandle
                    .position(x: windowState.size.width - 5, y: windowState.size.height - 5)
            }
        }
        .frame(width: windowState.size.width, height: windowState.size.height)
        .position(
            x: windowState.position.x + windowState.size.width / 2,
            y: windowState.position.y + windowState.size.height / 2
        )
        .zIndex(Double(windowState.zIndex))
        .onTapGesture {
            windowManager.bringToFront(windowState.id)
        }
    }

    // MARK: - Title Bar
    var titleBar: some View {
        HStack(spacing: 2) {
            // App icon (16x16)
            Win98Icons.appIcon(for: windowState.app)
                .frame(width: 16, height: 16)
                .padding(.leading, 3)

            // Title text
            Text(windowState.title)
                .font(Win98Font.title)
                .foregroundColor(Win98Color.titleText)
                .lineLimit(1)
                .padding(.leading, 2)

            Spacer()

            // Caption buttons
            HStack(spacing: 2) {
                CaptionButton(label: "_") {
                    windowManager.toggleMinimize(windowState.id)
                }
                CaptionButton(label: windowState.isMaximized ? "❐" : "□") {
                    windowState.toggleMaximize(in: screenSize)
                    windowManager.objectWillChange.send()
                }
                CaptionButton(label: "✕") {
                    windowManager.closeWindow(windowState.id)
                }
            }
            .padding(.trailing, 3)
        }
        .frame(height: Win98Metrics.titleBarHeight)
        .background(titleBarBackground)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !windowState.isMaximized {
                        windowState.position = CGPoint(
                            x: windowState.position.x + value.translation.width - dragOffset.width,
                            y: windowState.position.y + value.translation.height - dragOffset.height
                        )
                        dragOffset = value.translation
                        windowManager.bringToFront(windowState.id)
                    }
                }
                .onEnded { _ in
                    dragOffset = .zero
                    // Clamp position to screen
                    windowState.position.x = max(0, min(windowState.position.x, screenSize.width - windowState.size.width))
                    windowState.position.y = max(0, min(windowState.position.y, screenSize.height - Win98Metrics.taskbarHeight - windowState.size.height))
                }
        )
        .onTapGesture(count: 2) {
            windowState.toggleMaximize(in: screenSize)
            windowManager.objectWillChange.send()
        }
    }

    var titleBarBackground: some View {
        Group {
            if isActive {
                LinearGradient(
                    colors: [Win98Color.activeTitleLeft, Win98Color.activeTitleRight],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                LinearGradient(
                    colors: [Win98Color.inactiveTitle, Win98Color.inactiveTitle],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }

    // MARK: - Resize Handle
    var resizeHandle: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 16, height: 16)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isResizing {
                            isResizing = true
                            resizeStartSize = windowState.size
                        }
                        let newW = max(200, resizeStartSize.width + value.translation.width)
                        let newH = max(100, resizeStartSize.height + value.translation.height)
                        windowState.size = CGSize(width: newW, height: newH)
                        windowManager.objectWillChange.send()
                    }
                    .onEnded { _ in
                        isResizing = false
                    }
            )
        #if os(iOS)
        #else
            .onHover { hovering in }
        #endif
    }
}

// MARK: - Menu Bar for windows
struct Win98MenuBar: View {
    let items: [(String, [Win98MenuBarItem])]
    @State private var openMenu: String? = nil

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.0) { item in
                Win98MenuBarButton(
                    title: item.0,
                    items: item.1,
                    isOpen: openMenu == item.0,
                    onOpen: { openMenu = openMenu == item.0 ? nil : item.0 },
                    onClose: { openMenu = nil }
                )
            }
            Spacer()
        }
        .frame(height: 20)
        .background(Win98Color.buttonFace)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Win98Color.buttonShadow),
            alignment: .bottom
        )
    }
}

struct Win98MenuBarItem {
    let title: String
    let shortcut: String?
    let isSeparator: Bool
    let isEnabled: Bool
    let action: () -> Void

    init(_ title: String, shortcut: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void = {}) {
        self.title = title
        self.shortcut = shortcut
        self.isSeparator = false
        self.isEnabled = isEnabled
        self.action = action
    }

    static var separator: Win98MenuBarItem {
        return Win98MenuBarItem(_sep: true)
    }
}

extension Win98MenuBarItem {
    static func sep() -> Win98MenuBarItem {
        return Win98MenuBarItem(_sep: true)
    }
}

extension Win98MenuBarItem {
    init(_sep: Bool) {
        self.title = ""
        self.shortcut = nil
        self.isSeparator = true
        self.isEnabled = false
        self.action = {}
    }
}

struct Win98MenuBarButton: View {
    let title: String
    let items: [Win98MenuBarItem]
    let isOpen: Bool
    let onOpen: () -> Void
    let onClose: () -> Void
    @State private var buttonFrame: CGRect = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: onOpen) {
                Text(title)
                    .font(Win98Font.menu)
                    .foregroundColor(Win98Color.darkText)
                    .padding(.horizontal, 6)
                    .frame(height: 20)
                    .background(isOpen ? Win98Color.selectionBackground : Color.clear)
                    .foregroundColor(isOpen ? Win98Color.titleText : Win98Color.darkText)
            }
            .buttonStyle(PlainButtonStyle())

            if isOpen {
                Win98DropdownMenu(items: items, onClose: onClose)
                    .offset(x: 0, y: 20)
                    .zIndex(1000)
            }
        }
    }
}

struct Win98DropdownMenu: View {
    let items: [Win98MenuBarItem]
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                if item.isSeparator {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Win98Color.buttonShadow)
                            .frame(height: 1)
                        Rectangle()
                            .fill(Win98Color.buttonHighlight)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                } else {
                    Win98DropdownMenuItem(item: item, onClose: onClose)
                }
            }
        }
        .background(Win98Color.buttonFace)
        .win98Raised()
        .fixedSize()
        .zIndex(1000)
    }
}

struct Win98DropdownMenuItem: View {
    let item: Win98MenuBarItem
    let onClose: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            item.action()
            onClose()
        }) {
            HStack {
                Text(item.title)
                    .font(Win98Font.menu)
                    .foregroundColor(item.isEnabled ?
                        (isHovered ? Win98Color.titleText : Win98Color.darkText) :
                        Win98Color.disabledText)
                    .padding(.leading, 20)
                Spacer()
                if let sc = item.shortcut {
                    Text(sc)
                        .font(Win98Font.menu)
                        .foregroundColor(item.isEnabled ?
                            (isHovered ? Win98Color.titleText : Win98Color.darkText) :
                            Win98Color.disabledText)
                        .padding(.trailing, 8)
                }
            }
            .frame(minWidth: 150, maxWidth: .infinity)
            .frame(height: Win98Metrics.menuItemHeight)
            .background(isHovered && item.isEnabled ? Win98Color.selectionBackground : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!item.isEnabled)
        .onHover { h in isHovered = h }
    }
}

// MARK: - Status Bar
struct Win98StatusBar: View {
    let text: String

    var body: some View {
        HStack(spacing: 0) {
            Text(text)
                .font(Win98Font.small)
                .foregroundColor(Win98Color.darkText)
                .padding(.horizontal, 4)
                .frame(height: 18)
                .win98Well()
            Spacer()
        }
        .padding(2)
        .background(Win98Color.buttonFace)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Win98Color.buttonShadow),
            alignment: .top
        )
    }
}
