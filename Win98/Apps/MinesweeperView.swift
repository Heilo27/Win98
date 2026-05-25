import SwiftUI

// MARK: - Minesweeper
struct MinesweeperView: View {
    @StateObject private var game = MinesweeperGame()

    var body: some View {
        VStack(spacing: 0) {
            // Menu bar
            Win98MenuBar(items: [
                ("Game", [
                    Win98MenuBarItem("New", shortcut: "F2") { game.newGame() },
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Beginner") { game.setDifficulty(.beginner); game.newGame() },
                    Win98MenuBarItem("Intermediate") { game.setDifficulty(.intermediate); game.newGame() },
                    Win98MenuBarItem("Expert") { game.setDifficulty(.expert); game.newGame() },
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Best Times...") {},
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Exit") {},
                ]),
                ("Help", [
                    Win98MenuBarItem("Contents") {},
                    Win98MenuBarItem("About Minesweeper") {},
                ]),
            ])

            // Content
            VStack(spacing: 0) {
                // Status panel
                statusPanel

                // Divider
                Rectangle()
                    .fill(Win98Color.buttonShadow)
                    .frame(height: 1)
                    .padding(.horizontal, 6)

                // Grid
                mineGrid
                    .padding(6)
            }
            .padding(6)
            .background(Win98Color.buttonFace)
            .win98Raised()
            .padding(6)
            .background(Win98Color.buttonFace)
        }
        .background(Win98Color.buttonFace)
    }

    // MARK: - Status Panel
    var statusPanel: some View {
        HStack {
            // Mine counter (LED)
            LEDDisplay(value: game.minesRemaining, digits: 3)

            Spacer()

            // Smiley button
            SmileyButton(state: game.smileyState) {
                game.newGame()
            }

            Spacer()

            // Timer (LED)
            LEDDisplay(value: game.elapsedTime, digits: 3)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(Win98Color.buttonFace)
        .win98Sunken()
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
    }

    // MARK: - Mine Grid
    var mineGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<game.rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<game.cols, id: \.self) { col in
                        MineCell(cell: game.cells[row][col]) {
                            game.reveal(row: row, col: col)
                        } onFlag: {
                            game.toggleFlag(row: row, col: col)
                        }
                    }
                }
            }
        }
        .win98Sunken()
    }
}

// MARK: - LED Display (7-segment style)
struct LEDDisplay: View {
    let value: Int
    let digits: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(digitValues(), id: \.offset) { item in
                LEDDigit(digit: item.element)
            }
        }
        .padding(2)
        .background(Color.black)
        .win98Sunken()
    }

    private func digitValues() -> [(offset: Int, element: Int)] {
        let clamped = max(0, min(999, value))
        let s = String(format: "%03d", clamped)
        return s.enumerated().map { (offset: $0.offset, element: Int(String($0.element)) ?? 0) }
    }
}

// MARK: - LED Digit
struct LEDDigit: View {
    let digit: Int

    // 7-segment: segments[0..6] = top, top-right, bottom-right, bottom, bottom-left, top-left, middle
    static let segments: [[Bool]] = [
        [true, true, true, true, true, true, false],    // 0
        [false, true, true, false, false, false, false], // 1
        [true, true, false, true, true, false, true],    // 2
        [true, true, true, true, false, false, true],    // 3
        [false, true, true, false, false, true, true],   // 4
        [true, false, true, true, false, true, true],    // 5
        [true, false, true, true, true, true, true],     // 6
        [true, true, true, false, false, false, false],  // 7
        [true, true, true, true, true, true, true],      // 8
        [true, true, true, true, false, true, true],     // 9
    ]

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let thick: CGFloat = 2
            let segs = LEDDigit.segments[max(0, min(9, digit))]
            let onColor = Win98Color.ledRed
            let offColor = Win98Color.ledDim

            func drawSeg(_ on: Bool, _ path: Path) {
                ctx.fill(path, with: .color(on ? onColor : offColor))
            }

            // Top
            drawSeg(segs[0], segH(x: thick, y: 0, w: w - thick*2, t: thick))
            // Top-right
            drawSeg(segs[1], segV(x: w - thick, y: thick, h: h/2 - thick, t: thick))
            // Bottom-right
            drawSeg(segs[2], segV(x: w - thick, y: h/2, h: h/2 - thick, t: thick))
            // Bottom
            drawSeg(segs[3], segH(x: thick, y: h - thick, w: w - thick*2, t: thick))
            // Bottom-left
            drawSeg(segs[4], segV(x: 0, y: h/2, h: h/2 - thick, t: thick))
            // Top-left
            drawSeg(segs[5], segV(x: 0, y: thick, h: h/2 - thick, t: thick))
            // Middle
            drawSeg(segs[6], segH(x: thick, y: h/2 - thick/2, w: w - thick*2, t: thick))
        }
        .frame(width: 13, height: 23)
    }

    private func segH(x: CGFloat, y: CGFloat, w: CGFloat, t: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: x + t/2, y: y))
        p.addLine(to: CGPoint(x: x + w - t/2, y: y))
        p.addLine(to: CGPoint(x: x + w, y: y + t/2))
        p.addLine(to: CGPoint(x: x + w - t/2, y: y + t))
        p.addLine(to: CGPoint(x: x + t/2, y: y + t))
        p.addLine(to: CGPoint(x: x, y: y + t/2))
        p.closeSubpath()
        return p
    }

    private func segV(x: CGFloat, y: CGFloat, h: CGFloat, t: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: x, y: y + t/2))
        p.addLine(to: CGPoint(x: x + t/2, y: y))
        p.addLine(to: CGPoint(x: x + t, y: y + t/2))
        p.addLine(to: CGPoint(x: x + t, y: y + h - t/2))
        p.addLine(to: CGPoint(x: x + t/2, y: y + h))
        p.addLine(to: CGPoint(x: x, y: y + h - t/2))
        p.closeSubpath()
        return p
    }
}

// MARK: - Smiley Button
struct SmileyButton: View {
    let state: SmileyState
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(smileyEmoji)
                .font(.system(size: 16))
                .frame(width: 26, height: 26)
                .background(Win98Color.buttonFace)
                .modifier(BevelModifier(style: isPressed ? .sunken : .raised))
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    var smileyEmoji: String {
        switch state {
        case .normal: return "🙂"
        case .clicking: return "😮"
        case .won: return "😎"
        case .lost: return "😵"
        }
    }
}

// MARK: - Mine Cell
struct MineCell: View {
    let cell: MinesweeperCell
    let onReveal: () -> Void
    let onFlag: () -> Void
    @State private var isPressed = false

    var body: some View {
        ZStack {
            if cell.isRevealed {
                Rectangle()
                    .fill(Win98Color.buttonFace)
                    .win98Sunken()
                cellContent
            } else {
                Rectangle()
                    .fill(Win98Color.buttonFace)
                    .modifier(BevelModifier(style: isPressed ? .sunken : .raised))
                if cell.isFlagged {
                    Text("🚩")
                        .font(.system(size: 10))
                } else if cell.isQuestionMark {
                    Text("?")
                        .font(Win98Font.bold(11))
                        .foregroundColor(Win98Color.darkText)
                }
            }
        }
        .frame(width: 18, height: 18)
        .contentShape(Rectangle())
        .gesture(
            SimultaneousGesture(
                TapGesture()
                    .onEnded { onReveal() },
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in onFlag() }
            )
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    @ViewBuilder
    var cellContent: some View {
        if cell.isMine {
            if cell.isExploded {
                ZStack {
                    Rectangle().fill(Color.red)
                    Text("💣").font(.system(size: 10))
                }
            } else {
                Text("💣").font(.system(size: 10))
            }
        } else if cell.neighborCount > 0 {
            Text("\(cell.neighborCount)")
                .font(Win98Font.bold(11))
                .foregroundColor(numberColor(cell.neighborCount))
        }
    }

    func numberColor(_ n: Int) -> Color {
        switch n {
        case 1: return Color(hex: "#0000FF")
        case 2: return Color(hex: "#007B00")
        case 3: return Color(hex: "#FF0000")
        case 4: return Color(hex: "#000080")
        case 5: return Color(hex: "#7B0000")
        case 6: return Color(hex: "#008080")
        case 7: return Color(hex: "#000000")
        case 8: return Color(hex: "#808080")
        default: return Color(hex: "#000000")
        }
    }
}

// MARK: - Minesweeper Game Model
enum SmileyState {
    case normal, clicking, won, lost
}

enum MinesweeperDifficulty {
    case beginner    // 9x9, 10 mines
    case intermediate // 16x16, 40 mines
    case expert      // 16x30, 99 mines
}

struct MinesweeperCell {
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var isQuestionMark: Bool = false
    var isExploded: Bool = false
    var neighborCount: Int = 0
}

class MinesweeperGame: ObservableObject {
    @Published var cells: [[MinesweeperCell]] = []
    @Published var smileyState: SmileyState = .normal
    @Published var minesRemaining: Int = 10
    @Published var elapsedTime: Int = 0
    @Published var gameOver: Bool = false
    @Published var gameWon: Bool = false

    var rows: Int = 9
    var cols: Int = 9
    var totalMines: Int = 10
    private var initialized: Bool = false
    private var timer: Timer?
    private var difficulty: MinesweeperDifficulty = .beginner

    init() {
        newGame()
    }

    func setDifficulty(_ d: MinesweeperDifficulty) {
        difficulty = d
        switch d {
        case .beginner: rows = 9; cols = 9; totalMines = 10
        case .intermediate: rows = 16; cols = 16; totalMines = 40
        case .expert: rows = 16; cols = 30; totalMines = 99
        }
    }

    func newGame() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        minesRemaining = totalMines
        smileyState = .normal
        gameOver = false
        gameWon = false
        initialized = false
        cells = Array(repeating: Array(repeating: MinesweeperCell(), count: cols), count: rows)
    }

    private func initBoard(firstRow: Int, firstCol: Int) {
        initialized = true
        // Place mines, avoiding first click
        var positions = [(Int, Int)]()
        for r in 0..<rows {
            for c in 0..<cols {
                if abs(r - firstRow) > 1 || abs(c - firstCol) > 1 {
                    positions.append((r, c))
                }
            }
        }
        positions.shuffle()
        let mineCount = min(totalMines, positions.count)
        for i in 0..<mineCount {
            let (r, c) = positions[i]
            cells[r][c].isMine = true
        }
        // Calculate neighbor counts
        for r in 0..<rows {
            for c in 0..<cols {
                if !cells[r][c].isMine {
                    cells[r][c].neighborCount = countNeighborMines(r, c)
                }
            }
        }
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !self.gameOver && !self.gameWon {
                    self.elapsedTime = min(999, self.elapsedTime + 1)
                }
            }
        }
    }

    func reveal(row: Int, col: Int) {
        guard !gameOver && !gameWon else { return }
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return }
        guard !cells[row][col].isRevealed && !cells[row][col].isFlagged else { return }

        if !initialized {
            initBoard(firstRow: row, firstCol: col)
        }

        if cells[row][col].isMine {
            cells[row][col].isRevealed = true
            cells[row][col].isExploded = true
            revealAllMines()
            smileyState = .lost
            gameOver = true
            timer?.invalidate()
            return
        }

        floodReveal(row, col)
        checkWin()
    }

    private func floodReveal(_ r: Int, _ c: Int) {
        guard r >= 0 && r < rows && c >= 0 && c < cols else { return }
        guard !cells[r][c].isRevealed && !cells[r][c].isFlagged && !cells[r][c].isMine else { return }
        cells[r][c].isRevealed = true
        if cells[r][c].neighborCount == 0 {
            for dr in -1...1 {
                for dc in -1...1 {
                    if dr != 0 || dc != 0 {
                        floodReveal(r + dr, c + dc)
                    }
                }
            }
        }
    }

    func toggleFlag(row: Int, col: Int) {
        guard !gameOver && !gameWon else { return }
        guard !cells[row][col].isRevealed else { return }
        if cells[row][col].isFlagged {
            cells[row][col].isFlagged = false
            cells[row][col].isQuestionMark = true
            minesRemaining += 1
        } else if cells[row][col].isQuestionMark {
            cells[row][col].isQuestionMark = false
        } else {
            cells[row][col].isFlagged = true
            minesRemaining -= 1
        }
    }

    private func revealAllMines() {
        for r in 0..<rows {
            for c in 0..<cols {
                if cells[r][c].isMine && !cells[r][c].isFlagged {
                    cells[r][c].isRevealed = true
                }
            }
        }
    }

    private func checkWin() {
        let unrevealedNonMines = (0..<rows).flatMap { r in (0..<cols).map { c in (r,c) } }
            .filter { !cells[$0.0][$0.1].isRevealed && !cells[$0.0][$0.1].isMine }
        if unrevealedNonMines.isEmpty {
            smileyState = .won
            gameWon = true
            timer?.invalidate()
            // Auto-flag all mines
            for r in 0..<rows {
                for c in 0..<cols {
                    if cells[r][c].isMine { cells[r][c].isFlagged = true }
                }
            }
            minesRemaining = 0
        }
    }

    private func countNeighborMines(_ r: Int, _ c: Int) -> Int {
        var count = 0
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = r + dr, nc = c + dc
                if nr >= 0 && nr < rows && nc >= 0 && nc < cols && cells[nr][nc].isMine {
                    count += 1
                }
            }
        }
        return count
    }
}
