import SwiftUI
import Combine

// MARK: - Window App Type
enum Win98AppType: String, CaseIterable, Identifiable {
    case myComputer = "My Computer"
    case myDocuments = "My Documents"
    case notepad = "Notepad"
    case calculator = "Calculator"
    case minesweeper = "Minesweeper"
    case solitaire = "Solitaire"
    case recycleBin = "Recycle Bin"
    case networkNeighborhood = "Network Neighborhood"
    case explorer = "Windows Explorer"
    case internetExplorer = "Internet Explorer"
    case shutDown = "Shut Down Windows"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .myComputer: return "myComputer"
        case .myDocuments: return "myDocuments"
        case .notepad: return "notepad"
        case .calculator: return "calculator"
        case .minesweeper: return "minesweeper"
        case .solitaire: return "solitaire"
        case .recycleBin: return "recycleBin"
        case .networkNeighborhood: return "networkNeighborhood"
        case .explorer: return "explorer"
        case .internetExplorer: return "internetExplorer"
        case .shutDown: return "shutDown"
        }
    }

    var defaultSize: CGSize {
        switch self {
        case .myComputer: return CGSize(width: 420, height: 320)
        case .myDocuments: return CGSize(width: 420, height: 320)
        case .notepad: return CGSize(width: 400, height: 300)
        case .calculator: return CGSize(width: 240, height: 280)
        case .minesweeper: return CGSize(width: 200, height: 240)
        case .solitaire: return CGSize(width: 640, height: 440)
        case .recycleBin: return CGSize(width: 380, height: 280)
        case .networkNeighborhood: return CGSize(width: 380, height: 280)
        case .explorer: return CGSize(width: 500, height: 380)
        case .internetExplorer: return CGSize(width: 680, height: 500)
        case .shutDown: return CGSize(width: 320, height: 180)
        }
    }
}

// MARK: - Window State
class Win98WindowState: ObservableObject, Identifiable {
    let id: UUID
    let app: Win98AppType
    @Published var title: String
    @Published var position: CGPoint
    @Published var size: CGSize
    @Published var isMinimized: Bool = false
    @Published var isMaximized: Bool = false
    @Published var zIndex: Int
    private var preMaximizeRect: CGRect = .zero

    init(app: Win98AppType, position: CGPoint, zIndex: Int) {
        self.id = UUID()
        self.app = app
        self.title = app.rawValue
        self.position = position
        self.size = app.defaultSize
        self.zIndex = zIndex
    }

    func toggleMaximize(in screenSize: CGSize) {
        if isMaximized {
            position = preMaximizeRect.origin
            size = preMaximizeRect.size
            isMaximized = false
        } else {
            preMaximizeRect = CGRect(origin: position, size: size)
            position = CGPoint(x: 0, y: 0)
            size = CGSize(width: screenSize.width, height: screenSize.height - Win98Metrics.taskbarHeight)
            isMaximized = true
        }
    }
}

// MARK: - Window Manager
class WindowManager: ObservableObject {
    @Published var windows: [Win98WindowState] = []
    @Published var showStartMenu: Bool = false
    @Published var showShutDownDialog: Bool = false
    @Published var recycleHasFull: Bool = false
    @Published var desktopNotes: [String] = []

    private var nextZIndex: Int = 1

    var visibleWindows: [Win98WindowState] {
        windows.filter { !$0.isMinimized }
    }

    var taskbarWindows: [Win98WindowState] {
        windows
    }

    func openApp(_ app: Win98AppType, screenSize: CGSize) {
        // Don't open shut down as a real window
        if app == .shutDown {
            showShutDownDialog = true
            return
        }
        // Bring existing to front if already open
        if let existing = windows.first(where: { $0.app == app }) {
            existing.isMinimized = false
            bringToFront(existing.id)
            return
        }
        let offset = CGFloat(windows.count % 8) * 20
        let pos = CGPoint(
            x: 60 + offset,
            y: 40 + offset
        )
        let window = Win98WindowState(app: app, position: pos, zIndex: nextZIndex)
        nextZIndex += 1
        windows.append(window)
        showStartMenu = false
    }

    func closeWindow(_ id: UUID) {
        windows.removeAll { $0.id == id }
    }

    func bringToFront(_ id: UUID) {
        guard let window = windows.first(where: { $0.id == id }) else { return }
        window.zIndex = nextZIndex
        nextZIndex += 1
        objectWillChange.send()
    }

    func toggleMinimize(_ id: UUID) {
        guard let window = windows.first(where: { $0.id == id }) else { return }
        window.isMinimized.toggle()
        if !window.isMinimized {
            bringToFront(id)
        }
        objectWillChange.send()
    }

    var activeWindowID: UUID? {
        windows.filter { !$0.isMinimized }.max(by: { $0.zIndex < $1.zIndex })?.id
    }

    func toggleStartMenu() {
        showStartMenu.toggle()
    }
}
