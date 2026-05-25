import SwiftUI

// MARK: - Win98 Icon Drawing
struct Win98Icons {

    // App icon dispatcher
    @ViewBuilder
    static func appIcon(for app: Win98AppType) -> some View {
        switch app {
        case .myComputer:
            MyComputerIcon()
        case .myDocuments:
            MyDocumentsIcon()
        case .recycleBin:
            RecycleBinIcon(isFull: false)
        case .networkNeighborhood:
            NetworkNeighborhoodIcon()
        case .notepad:
            NotepadIcon()
        case .calculator:
            CalculatorIcon()
        case .minesweeper:
            MinesweeperIcon()
        case .solitaire:
            SolitaireIcon()
        case .explorer:
            ExplorerIcon()
        case .internetExplorer:
            InternetExplorerIcon()
        default:
            GenericIcon()
        }
    }
}

// MARK: - My Computer Icon
struct MyComputerIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Monitor body
            let monitor = CGRect(x: 4*s, y: 2*s, width: 24*s, height: 18*s)
            ctx.fill(Path(roundedRect: monitor, cornerRadius: 0), with: .color(.init(hex: "#C0C0C0")))
            // Monitor screen
            let screen = CGRect(x: 6*s, y: 4*s, width: 20*s, height: 13*s)
            ctx.fill(Path(screen), with: .color(.init(hex: "#008080")))
            // Screen border
            ctx.stroke(Path(screen), with: .color(.black), lineWidth: s)
            // Monitor stand
            var stand = Path()
            stand.move(to: CGPoint(x: 13*s, y: 20*s))
            stand.addLine(to: CGPoint(x: 19*s, y: 20*s))
            stand.addLine(to: CGPoint(x: 21*s, y: 24*s))
            stand.addLine(to: CGPoint(x: 11*s, y: 24*s))
            stand.closeSubpath()
            ctx.fill(stand, with: .color(.init(hex: "#C0C0C0")))
            // Base
            ctx.fill(Path(CGRect(x: 8*s, y: 24*s, width: 16*s, height: 2*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 8*s, y: 24*s, width: 16*s, height: 2*s)), with: .color(.black), lineWidth: s)
            // Tower (small)
            ctx.fill(Path(CGRect(x: 22*s, y: 14*s, width: 6*s, height: 10*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 22*s, y: 14*s, width: 6*s, height: 10*s)), with: .color(.black), lineWidth: s)
            // Floppy slot on tower
            ctx.fill(Path(CGRect(x: 23*s, y: 17*s, width: 4*s, height: 1*s)), with: .color(.gray))
            ctx.fill(Path(CGRect(x: 23*s, y: 19*s, width: 2*s, height: 2*s)), with: .color(.gray))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - My Documents Icon
struct MyDocumentsIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Folder back
            var folder = Path()
            folder.move(to: CGPoint(x: 2*s, y: 10*s))
            folder.addLine(to: CGPoint(x: 2*s, y: 26*s))
            folder.addLine(to: CGPoint(x: 30*s, y: 26*s))
            folder.addLine(to: CGPoint(x: 30*s, y: 12*s))
            folder.addLine(to: CGPoint(x: 14*s, y: 12*s))
            folder.addLine(to: CGPoint(x: 11*s, y: 10*s))
            folder.closeSubpath()
            ctx.fill(folder, with: .color(.init(hex: "#FFCF00")))
            ctx.stroke(folder, with: .color(.black), lineWidth: s)
            // Document inside
            let doc = CGRect(x: 12*s, y: 8*s, width: 14*s, height: 18*s)
            ctx.fill(Path(doc), with: .color(.white))
            ctx.stroke(Path(doc), with: .color(.black), lineWidth: s)
            // Fold corner
            var fold = Path()
            fold.move(to: CGPoint(x: 22*s, y: 8*s))
            fold.addLine(to: CGPoint(x: 26*s, y: 12*s))
            fold.addLine(to: CGPoint(x: 22*s, y: 12*s))
            fold.closeSubpath()
            ctx.fill(fold, with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(fold, with: .color(.black), lineWidth: s)
            // Lines on doc
            for i in 0..<4 {
                let y = CGFloat(14 + i*2) * s
                ctx.stroke(Path(CGRect(x: 14*s, y: y, width: 9*s, height: s)), with: .color(.gray), lineWidth: s)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Recycle Bin Icon
struct RecycleBinIcon: View {
    var isFull: Bool = false
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Bin body (trapezoid)
            var bin = Path()
            bin.move(to: CGPoint(x: 7*s, y: 10*s))
            bin.addLine(to: CGPoint(x: 4*s, y: 29*s))
            bin.addLine(to: CGPoint(x: 28*s, y: 29*s))
            bin.addLine(to: CGPoint(x: 25*s, y: 10*s))
            bin.closeSubpath()
            ctx.fill(bin, with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(bin, with: .color(.black), lineWidth: s)
            // Lid
            ctx.fill(Path(CGRect(x: 5*s, y: 7*s, width: 22*s, height: 3*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 5*s, y: 7*s, width: 22*s, height: 3*s)), with: .color(.black), lineWidth: s)
            // Handle on lid
            ctx.fill(Path(CGRect(x: 12*s, y: 5*s, width: 8*s, height: 3*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 12*s, y: 5*s, width: 8*s, height: 3*s)), with: .color(.black), lineWidth: s)
            // Vertical lines on bin
            for x in [12, 16, 20] {
                ctx.stroke(Path(CGRect(x: CGFloat(x)*s, y: 12*s, width: s, height: 14*s)), with: .color(.gray), lineWidth: s)
            }
            // Paper if full
            if isFull {
                var paper = Path()
                paper.move(to: CGPoint(x: 14*s, y: 5*s))
                paper.addLine(to: CGPoint(x: 12*s, y: 1*s))
                paper.addLine(to: CGPoint(x: 20*s, y: 1*s))
                paper.addLine(to: CGPoint(x: 18*s, y: 5*s))
                ctx.fill(paper, with: .color(.white))
                ctx.stroke(paper, with: .color(.black), lineWidth: s)
            }
            // Recycle arrows
            ctx.stroke(makeArrow(in: sz, s: s), with: .color(.init(hex: "#008000")), lineWidth: s * 1.5)
        }
        .frame(width: size, height: size)
    }

    private func makeArrow(in sz: CGSize, s: CGFloat) -> Path {
        var path = Path()
        let cx = sz.width / 2
        let cy = (12 + 29) / 2 * s
        let r: CGFloat = 7 * s
        path.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(-30), endAngle: .degrees(210), clockwise: false)
        return path
    }
}

// MARK: - Network Neighborhood Icon
struct NetworkNeighborhoodIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Left computer
            drawMiniComputer(ctx, x: 2*s, y: 8*s, s: s)
            // Right computer
            drawMiniComputer(ctx, x: 18*s, y: 8*s, s: s)
            // Connection line
            var line = Path()
            line.move(to: CGPoint(x: 12*s, y: 14*s))
            line.addLine(to: CGPoint(x: 20*s, y: 14*s))
            ctx.stroke(line, with: .color(.black), lineWidth: s)
        }
        .frame(width: size, height: size)
    }

    private func drawMiniComputer(_ ctx: GraphicsContext, x: CGFloat, y: CGFloat, s: CGFloat) {
        // Monitor
        ctx.fill(Path(CGRect(x: x, y: y, width: 12*s, height: 9*s)), with: .color(.init(hex: "#C0C0C0")))
        ctx.fill(Path(CGRect(x: x+1*s, y: y+1*s, width: 10*s, height: 6*s)), with: .color(.init(hex: "#008080")))
        ctx.stroke(Path(CGRect(x: x, y: y, width: 12*s, height: 9*s)), with: .color(.black), lineWidth: s)
        // Stand
        ctx.fill(Path(CGRect(x: x+4*s, y: y+9*s, width: 4*s, height: 2*s)), with: .color(.init(hex: "#C0C0C0")))
        ctx.fill(Path(CGRect(x: x+2*s, y: y+11*s, width: 8*s, height: s)), with: .color(.init(hex: "#C0C0C0")))
    }
}

// MARK: - Notepad Icon
struct NotepadIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            let doc = CGRect(x: 4*s, y: 2*s, width: 20*s, height: 26*s)
            ctx.fill(Path(doc), with: .color(.white))
            // Fold
            var fold = Path()
            fold.move(to: CGPoint(x: 20*s, y: 2*s))
            fold.addLine(to: CGPoint(x: 24*s, y: 6*s))
            fold.addLine(to: CGPoint(x: 20*s, y: 6*s))
            fold.closeSubpath()
            ctx.fill(fold, with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(fold, with: .color(.black), lineWidth: s)
            ctx.stroke(Path(doc), with: .color(.black), lineWidth: s)
            // Lines
            for i in 0..<6 {
                let lineY = CGFloat(9 + i*3) * s
                ctx.stroke(Path(CGRect(x: 7*s, y: lineY, width: 14*s, height: s)), with: .color(.init(hex: "#AAAAAA")), lineWidth: s)
            }
            // Pencil
            var pencil = Path()
            pencil.move(to: CGPoint(x: 22*s, y: 18*s))
            pencil.addLine(to: CGPoint(x: 28*s, y: 12*s))
            pencil.addLine(to: CGPoint(x: 30*s, y: 14*s))
            pencil.addLine(to: CGPoint(x: 24*s, y: 20*s))
            pencil.closeSubpath()
            ctx.fill(pencil, with: .color(.yellow))
            ctx.stroke(pencil, with: .color(.black), lineWidth: s)
            // Eraser
            ctx.fill(Path(CGRect(x: 22*s, y: 26*s, width: 6*s, height: 4*s)), with: .color(.pink))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Calculator Icon
struct CalculatorIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            let body = CGRect(x: 4*s, y: 2*s, width: 24*s, height: 28*s)
            ctx.fill(Path(body), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(body), with: .color(.black), lineWidth: s)
            // Display
            let disp = CGRect(x: 6*s, y: 4*s, width: 20*s, height: 6*s)
            ctx.fill(Path(disp), with: .color(.init(hex: "#9BE89B")))
            ctx.stroke(Path(disp), with: .color(.black), lineWidth: s)
            // Buttons grid
            let btnColors: [Color] = [.init(hex: "#C0C0C0"), .init(hex: "#808080")]
            for row in 0..<4 {
                for col in 0..<4 {
                    let bx = CGFloat(6 + col * 5) * s
                    let by = CGFloat(12 + row * 5) * s
                    let btn = CGRect(x: bx, y: by, width: 4*s, height: 4*s)
                    ctx.fill(Path(btn), with: .color(row == 3 && col == 3 ? .init(hex: "#CC0000") : btnColors[0]))
                    ctx.stroke(Path(btn), with: .color(.black), lineWidth: s * 0.5)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Minesweeper Icon
struct MinesweeperIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Grid background
            ctx.fill(Path(CGRect(x: 2*s, y: 2*s, width: 28*s, height: 28*s)), with: .color(.init(hex: "#C0C0C0")))
            // Draw some tiles
            let tileSize: CGFloat = 8 * s
            for row in 0..<3 {
                for col in 0..<3 {
                    let tx = CGFloat(2 + col * 9) * s + s
                    let ty = CGFloat(2 + row * 9) * s + s
                    let tile = CGRect(x: tx, y: ty, width: tileSize, height: tileSize)
                    ctx.fill(Path(tile), with: .color(.init(hex: "#C0C0C0")))
                    ctx.stroke(Path(tile), with: .color(.black), lineWidth: s * 0.5)
                }
            }
            // Mine in center
            let cx = 16 * s
            let cy = 16 * s
            ctx.fill(Path(ellipseIn: CGRect(x: cx-4*s, y: cy-4*s, width: 8*s, height: 8*s)), with: .color(.black))
            // Spikes
            for angle in stride(from: 0.0, to: 360.0, by: 45.0) {
                let rad = angle * .pi / 180
                var spike = Path()
                spike.move(to: CGPoint(x: cx, y: cy))
                spike.addLine(to: CGPoint(x: cx + cos(rad)*6*s, y: cy + sin(rad)*6*s))
                ctx.stroke(spike, with: .color(.black), lineWidth: s * 1.5)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Solitaire Icon
struct SolitaireIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Green felt
            ctx.fill(Path(CGRect(x: 0, y: 0, width: sz.width, height: sz.height)), with: .color(.init(hex: "#007B00")))
            // Cards
            let cardW: CGFloat = 12 * s
            let cardH: CGFloat = 18 * s
            // Back card
            ctx.fill(Path(CGRect(x: 4*s, y: 6*s, width: cardW, height: cardH)), with: .color(.init(hex: "#0000AA")))
            ctx.stroke(Path(CGRect(x: 4*s, y: 6*s, width: cardW, height: cardH)), with: .color(.black), lineWidth: s)
            // Front card
            let frontCard = CGRect(x: 14*s, y: 4*s, width: cardW, height: cardH)
            ctx.fill(Path(frontCard), with: .color(.white))
            ctx.stroke(Path(frontCard), with: .color(.black), lineWidth: s)
            // Heart on front card
            ctx.fill(heartPath(cx: 20*s, cy: 12*s, size: 5*s), with: .color(.init(hex: "#CC0000")))
        }
        .frame(width: size, height: size)
    }

    private func heartPath(cx: CGFloat, cy: CGFloat, size: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: cx, y: cy + size * 0.6))
        p.addCurve(to: CGPoint(x: cx - size, y: cy - size * 0.2),
                   control1: CGPoint(x: cx - size * 0.8, y: cy + size * 0.6),
                   control2: CGPoint(x: cx - size, y: cy + size * 0.2))
        p.addArc(center: CGPoint(x: cx - size * 0.5, y: cy - size * 0.2),
                 radius: size * 0.5, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addArc(center: CGPoint(x: cx + size * 0.5, y: cy - size * 0.2),
                 radius: size * 0.5, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addCurve(to: CGPoint(x: cx, y: cy + size * 0.6),
                   control1: CGPoint(x: cx + size, y: cy + size * 0.2),
                   control2: CGPoint(x: cx + size * 0.8, y: cy + size * 0.6))
        p.closeSubpath()
        return p
    }
}

// MARK: - Explorer Icon
struct ExplorerIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Globe
            ctx.fill(Path(ellipseIn: CGRect(x: 4*s, y: 4*s, width: 24*s, height: 24*s)), with: .color(.init(hex: "#0080FF")))
            // Latitude lines
            for i in [8, 16, 24] {
                let y = CGFloat(i) * s
                ctx.stroke(Path(CGRect(x: 4*s, y: y, width: 24*s, height: s)), with: .color(.white), lineWidth: s * 0.5)
            }
            // Longitude line
            var vLine = Path()
            vLine.move(to: CGPoint(x: 16*s, y: 4*s))
            vLine.addLine(to: CGPoint(x: 16*s, y: 28*s))
            ctx.stroke(vLine, with: .color(.white), lineWidth: s * 0.5)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Generic Icon
struct GenericIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            ctx.fill(Path(CGRect(x: 4*s, y: 4*s, width: 24*s, height: 24*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 4*s, y: 4*s, width: 24*s, height: 24*s)), with: .color(.black), lineWidth: s)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Desktop-sized Icons (larger 32pt display)
struct DesktopMyComputerIcon: View {
    var body: some View { MyComputerIcon(size: 32) }
}

// MARK: - Windows Logo (4 colored squares)
struct WindowsLogoView: View {
    var size: CGFloat = 14
    var body: some View {
        Canvas { ctx, sz in
            let half = sz.width / 2
            let gap: CGFloat = 1
            // Red (top-left)
            ctx.fill(Path(CGRect(x: 0, y: 0, width: half - gap, height: half - gap)), with: .color(.init(hex: "#FF0000")))
            // Green (top-right)
            ctx.fill(Path(CGRect(x: half + gap, y: 0, width: half - gap, height: half - gap)), with: .color(.init(hex: "#00FF00")))
            // Blue (bottom-left)
            ctx.fill(Path(CGRect(x: 0, y: half + gap, width: half - gap, height: half - gap)), with: .color(.init(hex: "#0000FF")))
            // Yellow (bottom-right)
            ctx.fill(Path(CGRect(x: half + gap, y: half + gap, width: half - gap, height: half - gap)), with: .color(.init(hex: "#FFFF00")))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Floppy Drive Icon
struct FloppyDriveIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Body
            ctx.fill(Path(CGRect(x: 4*s, y: 4*s, width: 24*s, height: 24*s)), with: .color(.init(hex: "#333333")))
            ctx.stroke(Path(CGRect(x: 4*s, y: 4*s, width: 24*s, height: 24*s)), with: .color(.black), lineWidth: s)
            // Label area
            ctx.fill(Path(CGRect(x: 7*s, y: 6*s, width: 15*s, height: 8*s)), with: .color(.white))
            // Slider
            ctx.fill(Path(CGRect(x: 7*s, y: 17*s, width: 18*s, height: 8*s)), with: .color(.init(hex: "#888888")))
            // Slot
            ctx.fill(Path(CGRect(x: 13*s, y: 17*s, width: 3*s, height: 8*s)), with: .color(.init(hex: "#C0C0C0")))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Hard Drive Icon
struct HardDriveIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Body
            ctx.fill(Path(CGRect(x: 2*s, y: 6*s, width: 28*s, height: 20*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 2*s, y: 6*s, width: 28*s, height: 20*s)), with: .color(.black), lineWidth: s)
            // Platters (ellipses)
            ctx.stroke(Path(ellipseIn: CGRect(x: 6*s, y: 9*s, width: 14*s, height: 14*s)), with: .color(.init(hex: "#808080")), lineWidth: s)
            ctx.stroke(Path(ellipseIn: CGRect(x: 10*s, y: 12*s, width: 7*s, height: 7*s)), with: .color(.init(hex: "#808080")), lineWidth: s)
            // Read arm
            var arm = Path()
            arm.move(to: CGPoint(x: 22*s, y: 10*s))
            arm.addLine(to: CGPoint(x: 13*s, y: 16*s))
            ctx.stroke(arm, with: .color(.black), lineWidth: s)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - CD-ROM Icon
struct CDROMIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Tray
            ctx.fill(Path(CGRect(x: 2*s, y: 6*s, width: 28*s, height: 20*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 2*s, y: 6*s, width: 28*s, height: 20*s)), with: .color(.black), lineWidth: s)
            // CD disc
            ctx.fill(Path(ellipseIn: CGRect(x: 8*s, y: 9*s, width: 16*s, height: 14*s)), with: .color(.init(hex: "#C8C8C8")))
            ctx.stroke(Path(ellipseIn: CGRect(x: 8*s, y: 9*s, width: 16*s, height: 14*s)), with: .color(.black), lineWidth: s)
            ctx.fill(Path(ellipseIn: CGRect(x: 14*s, y: 14*s, width: 4*s, height: 4*s)), with: .color(.init(hex: "#C0C0C0")))
            // Eject button
            ctx.fill(Path(CGRect(x: 24*s, y: 10*s, width: 4*s, height: 8*s)), with: .color(.init(hex: "#AAAAAA")))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Control Panel Icon
struct ControlPanelIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Frame
            ctx.fill(Path(CGRect(x: 2*s, y: 2*s, width: 28*s, height: 28*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 2*s, y: 2*s, width: 28*s, height: 28*s)), with: .color(.black), lineWidth: s)
            // 4 colored icons inside
            let colors: [Color] = [.red, .green, .blue, .yellow]
            let positions: [(CGFloat, CGFloat)] = [(4, 4), (18, 4), (4, 18), (18, 18)]
            for i in 0..<4 {
                let (px, py) = positions[i]
                ctx.fill(Path(CGRect(x: px*s, y: py*s, width: 10*s, height: 10*s)), with: .color(colors[i].opacity(0.8)))
                ctx.stroke(Path(CGRect(x: px*s, y: py*s, width: 10*s, height: 10*s)), with: .color(.black), lineWidth: s)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Internet Explorer Icon (classic blue "e" with orbit ring)
struct InternetExplorerIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Orbit ring (golden/yellow ellipse tilted) — drawn first (behind e)
            var ring = Path()
            ring.addEllipse(in: CGRect(x: 4*s, y: 12*s, width: 24*s, height: 10*s))
            ctx.stroke(ring, with: .color(Color(hex: "#FFD700")), lineWidth: 2.5*s)

            // Blue "e" shape — simplified block letter
            // Outer arc (big C shape)
            let eRect = CGRect(x: 5*s, y: 4*s, width: 22*s, height: 24*s)
            var ePath = Path()
            ePath.addArc(center: CGPoint(x: 16*s, y: 16*s), radius: 11*s, startAngle: .degrees(-20), endAngle: .degrees(200), clockwise: false)
            ctx.stroke(ePath, with: .color(Color(hex: "#1461B4")), lineWidth: 7*s)

            // Horizontal bar through middle (the "e" crossbar)
            var bar = Path()
            bar.move(to: CGPoint(x: 6*s, y: 16*s))
            bar.addLine(to: CGPoint(x: 24*s, y: 16*s))
            ctx.stroke(bar, with: .color(Color(hex: "#1461B4")), lineWidth: 2.5*s)

            // Fill the interior white so it reads as an "e" not just an arc
            var inner = Path()
            inner.addEllipse(in: CGRect(x: 9*s, y: 8*s, width: 14*s, height: 16*s))
            ctx.fill(inner, with: .color(Color(hex: "#FFFFFF").opacity(0.0))) // transparent — just clips

            // Redraw the right side of e as a termination
            var tail = Path()
            tail.move(to: CGPoint(x: 24*s, y: 10*s))
            tail.addLine(to: CGPoint(x: 26*s, y: 14*s))
            ctx.stroke(tail, with: .color(Color(hex: "#1461B4")), lineWidth: 3*s)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Printers Icon
struct PrintersIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            // Printer body
            ctx.fill(Path(CGRect(x: 2*s, y: 10*s, width: 28*s, height: 16*s)), with: .color(.init(hex: "#C0C0C0")))
            ctx.stroke(Path(CGRect(x: 2*s, y: 10*s, width: 28*s, height: 16*s)), with: .color(.black), lineWidth: s)
            // Paper tray
            ctx.fill(Path(CGRect(x: 6*s, y: 4*s, width: 20*s, height: 8*s)), with: .color(.white))
            ctx.stroke(Path(CGRect(x: 6*s, y: 4*s, width: 20*s, height: 8*s)), with: .color(.black), lineWidth: s)
            // Output paper
            ctx.fill(Path(CGRect(x: 6*s, y: 22*s, width: 20*s, height: 6*s)), with: .color(.white))
            ctx.stroke(Path(CGRect(x: 6*s, y: 22*s, width: 20*s, height: 6*s)), with: .color(.black), lineWidth: s)
            // Indicator light
            ctx.fill(Path(ellipseIn: CGRect(x: 22*s, y: 14*s, width: 4*s, height: 4*s)), with: .color(.green))
        }
        .frame(width: size, height: size)
    }
}
