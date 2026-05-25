import SwiftUI

// Windows 98 boot screen — black background, logo, progress bar, then fades to desktop
struct BootScreenView: View {
    var onComplete: () -> Void

    @State private var progress: CGFloat = 0
    @State private var barCount: Int = 0
    @State private var fadingOut: Bool = false

    // The progress bar animates in discrete chunks like the real Win98 boot
    private let totalBars = 28
    private let barWidth: CGFloat = 8
    private let barHeight: CGFloat = 14
    private let barGap: CGFloat = 2
    private let bootDuration: Double = 3.2  // total seconds before desktop appears

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Windows 98 logo block
                VStack(spacing: 16) {
                    // "Windows" wordmark
                    HStack(spacing: 0) {
                        Win98FourSquare(size: 38)
                            .padding(.trailing, 12)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Windows")
                                .font(.custom("Georgia", size: 38))
                                .fontWeight(.light)
                                .italic()
                                .foregroundColor(.white)
                                .kerning(-0.5)
                            HStack(spacing: 0) {
                                Text("98")
                                    .font(.custom("Georgia", size: 38))
                                    .fontWeight(.light)
                                    .italic()
                                    .foregroundColor(.white)
                                    .kerning(-0.5)
                                Text("™")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .offset(y: -16)
                            }
                        }
                    }

                    // Tagline — exact Win98 text
                    Text("Microsoft")
                        .font(.custom("Arial", size: 13))
                        .foregroundColor(Color(white: 0.75))
                        .kerning(2)
                }

                Spacer().frame(height: 60)

                // Progress bar area — discrete chunked blocks, Win98 style
                VStack(spacing: 8) {
                    // The segmented progress bar
                    HStack(spacing: barGap) {
                        ForEach(0..<totalBars, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(i < barCount ? Color(hex: "#003399") : Color.clear)
                                .frame(width: barWidth, height: barHeight)
                        }
                    }
                    .padding(3)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color(white: 0.3), lineWidth: 1)
                    )
                }

                Spacer().frame(height: 80)
            }
        }
        .opacity(fadingOut ? 0 : 1)
        .animation(.easeIn(duration: 0.4), value: fadingOut)
        .onAppear {
            animateBars()
        }
    }

    private func animateBars() {
        let interval = bootDuration / Double(totalBars)
        for i in 0...totalBars {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                if i < totalBars {
                    barCount = i + 1
                } else {
                    // Done — fade out and call completion
                    fadingOut = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        onComplete()
                    }
                }
            }
        }
    }
}

// The classic 4-colour Windows flag logo
struct Win98FourSquare: View {
    var size: CGFloat = 32

    var body: some View {
        let half = size / 2
        let gap: CGFloat = 2
        Canvas { ctx, _ in
            // Red — top left
            ctx.fill(Path(CGRect(x: 0, y: 0, width: half - gap/2, height: half - gap/2)), with: .color(Color(hex: "#FF0000")))
            // Green — top right
            ctx.fill(Path(CGRect(x: half + gap/2, y: 0, width: half - gap/2, height: half - gap/2)), with: .color(Color(hex: "#00FF00")))
            // Blue — bottom left
            ctx.fill(Path(CGRect(x: 0, y: half + gap/2, width: half - gap/2, height: half - gap/2)), with: .color(Color(hex: "#0000FF")))
            // Yellow — bottom right
            ctx.fill(Path(CGRect(x: half + gap/2, y: half + gap/2, width: half - gap/2, height: half - gap/2)), with: .color(Color(hex: "#FFFF00")))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    BootScreenView(onComplete: {})
}
