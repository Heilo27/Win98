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
        // Highlight lines (top + left edges)
        var highlight = Path()
        highlight.move(to: CGPoint(x: 0, y: h - 1)); highlight.addLine(to: CGPoint(x: 0, y: 0))
        highlight.move(to: CGPoint(x: 0, y: 0)); highlight.addLine(to: CGPoint(x: w - 1, y: 0))
        highlight.move(to: CGPoint(x: 1, y: h - 2)); highlight.addLine(to: CGPoint(x: 1, y: 1))
        highlight.move(to: CGPoint(x: 1, y: 1)); highlight.addLine(to: CGPoint(x: w - 2, y: 1))
        ctx.stroke(highlight, with: .color(Win98Color.buttonHighlight), lineWidth: 1)

        // Shadow lines (bottom + right edges)
        var shadow = Path()
        shadow.move(to: CGPoint(x: 0, y: h - 1)); shadow.addLine(to: CGPoint(x: w - 1, y: h - 1))
        shadow.move(to: CGPoint(x: w - 1, y: 0)); shadow.addLine(to: CGPoint(x: w - 1, y: h - 1))
        ctx.stroke(shadow, with: .color(Win98Color.buttonDarkShadow), lineWidth: 1)

        // Inner shadow lines
        var innerShadow = Path()
        innerShadow.move(to: CGPoint(x: 1, y: h - 2)); innerShadow.addLine(to: CGPoint(x: w - 2, y: h - 2))
        innerShadow.move(to: CGPoint(x: w - 2, y: 1)); innerShadow.addLine(to: CGPoint(x: w - 2, y: h - 2))
        ctx.stroke(innerShadow, with: .color(Win98Color.buttonShadow), lineWidth: 1)
    }

    // Sunken: inverted from raised
    private func drawSunken(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        // Shadow lines (top + left)
        var shadow = Path()
        shadow.move(to: CGPoint(x: 0, y: h - 1)); shadow.addLine(to: CGPoint(x: 0, y: 0))
        shadow.move(to: CGPoint(x: 0, y: 0)); shadow.addLine(to: CGPoint(x: w - 1, y: 0))
        shadow.move(to: CGPoint(x: 1, y: h - 2)); shadow.addLine(to: CGPoint(x: 1, y: 1))
        shadow.move(to: CGPoint(x: 1, y: 1)); shadow.addLine(to: CGPoint(x: w - 2, y: 1))
        ctx.stroke(shadow, with: .color(Win98Color.buttonDarkShadow), lineWidth: 1)

        // Highlight lines (bottom + right)
        var highlight = Path()
        highlight.move(to: CGPoint(x: 0, y: h - 1)); highlight.addLine(to: CGPoint(x: w - 1, y: h - 1))
        highlight.move(to: CGPoint(x: w - 1, y: 0)); highlight.addLine(to: CGPoint(x: w - 1, y: h - 1))
        ctx.stroke(highlight, with: .color(Win98Color.buttonHighlight), lineWidth: 1)

        // Inner highlight lines
        var innerHighlight = Path()
        innerHighlight.move(to: CGPoint(x: 1, y: h - 2)); innerHighlight.addLine(to: CGPoint(x: w - 2, y: h - 2))
        innerHighlight.move(to: CGPoint(x: w - 2, y: 1)); innerHighlight.addLine(to: CGPoint(x: w - 2, y: h - 2))
        ctx.stroke(innerHighlight, with: .color(Win98Color.buttonLight), lineWidth: 1)
    }

    // Flat: simple gray border
    private func drawFlat(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        var path = Path()
        path.addRect(CGRect(x: 0, y: 0, width: w, height: h))
        ctx.stroke(path, with: .color(Win98Color.buttonShadow), lineWidth: 1)
    }

    // Well (input field): sunken, no inner border needed visually
    private func drawWell(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        // Shadow lines (top + left)
        var shadow = Path()
        shadow.move(to: CGPoint(x: 0, y: h - 1)); shadow.addLine(to: CGPoint(x: 0, y: 0))
        shadow.move(to: CGPoint(x: 0, y: 0)); shadow.addLine(to: CGPoint(x: w - 1, y: 0))
        shadow.move(to: CGPoint(x: 1, y: h - 2)); shadow.addLine(to: CGPoint(x: 1, y: 1))
        shadow.move(to: CGPoint(x: 1, y: 1)); shadow.addLine(to: CGPoint(x: w - 2, y: 1))
        ctx.stroke(shadow, with: .color(Win98Color.buttonShadow), lineWidth: 1)

        // Highlight lines (bottom + right)
        var highlight = Path()
        highlight.move(to: CGPoint(x: 0, y: h - 1)); highlight.addLine(to: CGPoint(x: w - 1, y: h - 1))
        highlight.move(to: CGPoint(x: w - 1, y: 0)); highlight.addLine(to: CGPoint(x: w - 1, y: h - 1))
        ctx.stroke(highlight, with: .color(Win98Color.buttonHighlight), lineWidth: 1)

        // Inner dark shadow (top + left)
        var darkShadow = Path()
        darkShadow.move(to: CGPoint(x: 1, y: h - 2)); darkShadow.addLine(to: CGPoint(x: 1, y: 1))
        darkShadow.move(to: CGPoint(x: 1, y: 1)); darkShadow.addLine(to: CGPoint(x: w - 2, y: 1))
        ctx.stroke(darkShadow, with: .color(Win98Color.buttonDarkShadow), lineWidth: 1)

        // Inner light (bottom + right)
        var innerLight = Path()
        innerLight.move(to: CGPoint(x: 1, y: h - 2)); innerLight.addLine(to: CGPoint(x: w - 2, y: h - 2))
        innerLight.move(to: CGPoint(x: w - 2, y: 1)); innerLight.addLine(to: CGPoint(x: w - 2, y: h - 2))
        ctx.stroke(innerLight, with: .color(Win98Color.buttonLight), lineWidth: 1)
    }

    private func drawGroupBox(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        // top + left = shadow, bottom + right = highlight
        var shadow = Path()
        shadow.move(to: CGPoint(x: 0, y: h - 1)); shadow.addLine(to: CGPoint(x: 0, y: 8))
        shadow.move(to: CGPoint(x: 0, y: 8)); shadow.addLine(to: CGPoint(x: w - 1, y: 8))
        ctx.stroke(shadow, with: .color(Win98Color.buttonShadow), lineWidth: 1)

        var highlight = Path()
        highlight.move(to: CGPoint(x: 1, y: h - 1)); highlight.addLine(to: CGPoint(x: w - 1, y: h - 1))
        highlight.move(to: CGPoint(x: w - 1, y: 8)); highlight.addLine(to: CGPoint(x: w - 1, y: h - 1))
        ctx.stroke(highlight, with: .color(Win98Color.buttonHighlight), lineWidth: 1)
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
