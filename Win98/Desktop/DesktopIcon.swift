import SwiftUI

// MARK: - Desktop Icon
struct DesktopIcon: View {
    let app: Win98AppType
    let onOpen: () -> Void
    @State private var isSelected: Bool = false
    @State private var tapCount: Int = 0
    @State private var tapTimer: Timer? = nil

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if isSelected {
                    Rectangle()
                        .fill(Win98Color.selectionBackground)
                        .frame(width: 34, height: 34)
                }
                appIconView
                    .frame(width: 32, height: 32)
                    .colorMultiply(isSelected ? Color(hex: "#6060FF") : .white)
            }
            .frame(width: 38, height: 36)

            Text(app.rawValue)
                .font(Win98Font.small)
                .foregroundColor(Win98Color.titleText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 2)
                .padding(.vertical, 1)
                .background(isSelected ? Win98Color.selectionBackground : Win98Color.desktop)
                .frame(width: 70)
        }
        .frame(width: Win98Metrics.iconTouchSize + 22, height: Win98Metrics.iconTouchSize + 28)
        .contentShape(Rectangle())
        .onTapGesture {
            tapCount += 1
            tapTimer?.invalidate()
            tapTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                if tapCount >= 2 {
                    DispatchQueue.main.async { onOpen(); isSelected = false }
                } else {
                    DispatchQueue.main.async { isSelected = true }
                }
                tapCount = 0
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    isSelected = true
                }
        )
    }

    @ViewBuilder
    var appIconView: some View {
        switch app {
        case .myComputer:
            MyComputerIcon(size: 32)
        case .myDocuments:
            MyDocumentsIcon(size: 32)
        case .recycleBin:
            RecycleBinIcon(isFull: false, size: 32)
        case .networkNeighborhood:
            NetworkNeighborhoodIcon(size: 32)
        default:
            Win98Icons.appIcon(for: app)
        }
    }
}
