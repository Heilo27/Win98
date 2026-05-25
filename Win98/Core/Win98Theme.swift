import SwiftUI

// MARK: - Windows 98 Color Palette
enum Win98Color {
    static let desktop = Color(hex: "#008080")
    static let buttonFace = Color(hex: "#C0C0C0")
    static let buttonHighlight = Color(hex: "#FFFFFF")
    static let buttonShadow = Color(hex: "#808080")
    static let buttonDarkShadow = Color(hex: "#0A0A0A")
    static let buttonLight = Color(hex: "#DFDFDF")
    static let activeTitleLeft = Color(hex: "#000080")
    static let activeTitleRight = Color(hex: "#1084D0")
    static let inactiveTitle = Color(hex: "#808080")
    static let titleText = Color(hex: "#FFFFFF")
    static let windowBackground = Color(hex: "#FFFFFF")
    static let selectionBackground = Color(hex: "#000080")
    static let selectionText = Color(hex: "#FFFFFF")
    static let tooltipBackground = Color(hex: "#FFFFE1")
    static let menuBackground = Color(hex: "#FFFFFF")
    static let disabledText = Color(hex: "#808080")
    static let darkText = Color(hex: "#000000")
    static let windowBorder = Color(hex: "#0A0A0A")
    static let inactiveText = Color(hex: "#808080")
    static let startMenuBannerTop = Color(hex: "#000080")
    static let startMenuBannerBottom = Color(hex: "#1084D0")
    static let greenFelt = Color(hex: "#007B00")
    static let taskbarBackground = Color(hex: "#C0C0C0")
    static let ledRed = Color(hex: "#FF0000")
    static let ledBackground = Color(hex: "#000000")
    static let ledDim = Color(hex: "#3A0000")
}

// MARK: - Windows 98 Dimensions
enum Win98Metrics {
    static let titleBarHeight: CGFloat = 20
    static let captionButtonWidth: CGFloat = 16
    static let captionButtonHeight: CGFloat = 14
    static let windowBorderWidth: CGFloat = 2
    static let scrollbarWidth: CGFloat = 16
    static let standardButtonWidth: CGFloat = 75
    static let standardButtonHeight: CGFloat = 23
    static let taskbarHeight: CGFloat = 30
    static let menuItemHeight: CGFloat = 20
    static let menuSeparatorHeight: CGFloat = 5
    static let iconSize: CGFloat = 32
    static let iconTouchSize: CGFloat = 48
    static let desktopIconSpacingX: CGFloat = 75
    static let desktopIconSpacingY: CGFloat = 80
    static let startButtonWidth: CGFloat = 54
    static let taskbarButtonHeight: CGFloat = 22
    static let systemFontSize: CGFloat = 11
    static let menuFontSize: CGFloat = 11
    static let titleFontSize: CGFloat = 11
    static let cornerRadius: CGFloat = 0
}

// MARK: - Windows 98 Fonts
enum Win98Font {
    static func system(_ size: CGFloat = Win98Metrics.systemFontSize) -> Font {
        Font.custom("Menlo", size: size).weight(.regular)
    }
    static func bold(_ size: CGFloat = Win98Metrics.systemFontSize) -> Font {
        Font.custom("Menlo", size: size).weight(.bold)
    }
    static let ui = Font.custom("Menlo", size: Win98Metrics.systemFontSize)
    static let uiBold = Font.custom("Menlo", size: Win98Metrics.systemFontSize).weight(.bold)
    static let title = Font.custom("Menlo", size: Win98Metrics.titleFontSize).weight(.regular)
    static let menu = Font.custom("Menlo", size: Win98Metrics.menuFontSize)
    static let small = Font.custom("Menlo", size: 10)
}

// MARK: - Color Hex Init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
