import SwiftUI

// MARK: - Bevel Style
enum BevelStyle {
    case raised
    case sunken
    case flat
    case well
    case groupBox
}

// MARK: - Bevel Modifier
struct BevelModifier: ViewModifier {
    let style: BevelStyle

    func body(content: Content) -> some View {
        content
            .overlay(BevelBorder(style: style))
    }
}

// MARK: - Bevel Border Shape
struct BevelBorder: View {
    let style: BevelStyle

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Canvas { ctx, size in
                switch style {
                case .raised:
                    drawRaised(ctx: ctx, w: w, h: h)
                case .sunken:
                    drawSunken(ctx: ctx, w: w, h: h)
                case .flat:
                    drawFlat(ctx: ctx, w: w, h: h)
                case .well:
                    drawWell(ctx: ctx, w: w, h: h)
                case .groupBox:
                    drawGroupBox(ctx: ctx, w: w, h: h)
                }
            }
        }
    }

    // Raised button: outer top-left=white, outer bottom-right=dark; inner top-left=light, inner bottom-right=gray
    private func drawRaised(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        // Outer highlight (top + left) = white
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: 0, y: h-1), to: CGPoint(x: 0, y: 0))
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: 0, y: 0), to: CGPoint(x: w-1, y: 0))
        // Outer shadow (bottom + right) = dark
        drawLine(ctx: ctx, color: Win98Color.buttonDarkShadow,
                 from: CGPoint(x: 0, y: h-1), to: CGPoint(x: w-1, y: h-1))
        drawLine(ctx: ctx, color: Win98Color.buttonDarkShadow,
                 from: CGPoint(x: w-1, y: 0), to: CGPoint(x: w-1, y: h-1))
        // Inner highlight (top + left) = light gray
        drawLine(ctx: ctx, color: Win98Color.buttonLight,
                 from: CGPoint(x: 1, y: h-2), to: CGPoint(x: 1, y: 1))
        drawLine(ctx: ctx, color: Win98Color.buttonLight,
                 from: CGPoint(x: 1, y: 1), to: CGPoint(x: w-2, y: 1))
        // Inner shadow (bottom + right) = gray
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: 1, y: h-2), to: CGPoint(x: w-2, y: h-2))
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: w-2, y: 1), to: CGPoint(x: w-2, y: h-2))
    }

    // Sunken: inverted from raised
    private func drawSunken(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        // Outer shadow (top + left) = dark
        drawLine(ctx: ctx, color: Win98Color.buttonDarkShadow,
                 from: CGPoint(x: 0, y: h-1), to: CGPoint(x: 0, y: 0))
        drawLine(ctx: ctx, color: Win98Color.buttonDarkShadow,
                 from: CGPoint(x: 0, y: 0), to: CGPoint(x: w-1, y: 0))
        // Outer highlight (bottom + right) = white
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: 0, y: h-1), to: CGPoint(x: w-1, y: h-1))
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: w-1, y: 0), to: CGPoint(x: w-1, y: h-1))
        // Inner shadow (top + left) = gray
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: 1, y: h-2), to: CGPoint(x: 1, y: 1))
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: 1, y: 1), to: CGPoint(x: w-2, y: 1))
        // Inner highlight (bottom + right) = light
        drawLine(ctx: ctx, color: Win98Color.buttonLight,
                 from: CGPoint(x: 1, y: h-2), to: CGPoint(x: w-2, y: h-2))
        drawLine(ctx: ctx, color: Win98Color.buttonLight,
                 from: CGPoint(x: w-2, y: 1), to: CGPoint(x: w-2, y: h-2))
    }

    // Flat: simple gray border
    private func drawFlat(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        var path = Path()
        path.addRect(CGRect(x: 0, y: 0, width: w, height: h))
        ctx.stroke(path, with: .color(Win98Color.buttonShadow), lineWidth: 1)
    }

    // Well (input field): sunken, no inner border needed visually
    private func drawWell(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: 0, y: h-1), to: CGPoint(x: 0, y: 0))
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: 0, y: 0), to: CGPoint(x: w-1, y: 0))
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: 0, y: h-1), to: CGPoint(x: w-1, y: h-1))
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: w-1, y: 0), to: CGPoint(x: w-1, y: h-1))
        drawLine(ctx: ctx, color: Win98Color.buttonDarkShadow,
                 from: CGPoint(x: 1, y: h-2), to: CGPoint(x: 1, y: 1))
        drawLine(ctx: ctx, color: Win98Color.buttonDarkShadow,
                 from: CGPoint(x: 1, y: 1), to: CGPoint(x: w-2, y: 1))
        drawLine(ctx: ctx, color: Win98Color.buttonLight,
                 from: CGPoint(x: 1, y: h-2), to: CGPoint(x: w-2, y: h-2))
        drawLine(ctx: ctx, color: Win98Color.buttonLight,
                 from: CGPoint(x: w-2, y: 1), to: CGPoint(x: w-2, y: h-2))
    }

    private func drawGroupBox(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        // top + left = shadow, bottom + right = highlight
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: 0, y: h-1), to: CGPoint(x: 0, y: 8))
        drawLine(ctx: ctx, color: Win98Color.buttonShadow,
                 from: CGPoint(x: 0, y: 8), to: CGPoint(x: w-1, y: 8))
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: 1, y: h-1), to: CGPoint(x: w-1, y: h-1))
        drawLine(ctx: ctx, color: Win98Color.buttonHighlight,
                 from: CGPoint(x: w-1, y: 8), to: CGPoint(x: w-1, y: h-1))
    }

    private func drawLine(ctx: GraphicsContext, color: Color, from: CGPoint, to: CGPoint) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        ctx.stroke(path, with: .color(color), lineWidth: 1)
    }
}

// MARK: - View Extensions
extension View {
    func win98Raised() -> some View {
        self.modifier(BevelModifier(style: .raised))
    }
    func win98Sunken() -> some View {
        self.modifier(BevelModifier(style: .sunken))
    }
    func win98Well() -> some View {
        self.modifier(BevelModifier(style: .well))
    }
    func win98Flat() -> some View {
        self.modifier(BevelModifier(style: .flat))
    }
}

// MARK: - Window Panel (flat silver with bevel)
struct Win98Panel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Win98Color.buttonFace)
            .win98Raised()
    }
}

extension View {
    func win98Panel() -> some View {
        self.modifier(Win98Panel())
    }
}
