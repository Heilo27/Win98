import SwiftUI

// MARK: - Win98 Button Style
struct Win98ButtonStyle: ButtonStyle {
    var width: CGFloat? = nil
    var height: CGFloat = Win98Metrics.standardButtonHeight
    var isActive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Win98Font.ui)
            .foregroundColor(Win98Color.darkText)
            .frame(width: width, height: height)
            .padding(.horizontal, width == nil ? 8 : 0)
            .background(Win98Color.buttonFace)
            .modifier(BevelModifier(style: configuration.isPressed || isActive ? .sunken : .raised))
            .contentShape(Rectangle())
    }
}

// MARK: - Caption Button (title bar min/max/close)
struct CaptionButton: View {
    let label: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Win98Color.darkText)
                .frame(width: Win98Metrics.captionButtonWidth, height: Win98Metrics.captionButtonHeight)
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
}

// MARK: - Standard Win98 Button
struct Win98Button: View {
    let title: String
    let action: () -> Void
    var width: CGFloat? = Win98Metrics.standardButtonWidth
    var isDefault: Bool = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Win98Font.ui)
                .foregroundColor(Win98Color.darkText)
                .frame(width: width, height: Win98Metrics.standardButtonHeight)
                .background(Win98Color.buttonFace)
                .modifier(BevelModifier(style: isPressed ? .sunken : .raised))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Win98Color.darkText, lineWidth: isDefault ? 1 : 0)
                        .padding(isDefault ? -1 : 0)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Toolbar Button
struct Win98ToolbarButton: View {
    let iconName: String
    let label: String
    let action: () -> Void
    var isEnabled: Bool = true
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .foregroundColor(isEnabled ? Win98Color.darkText : Win98Color.disabledText)
                Text(label)
                    .font(Win98Font.small)
                    .foregroundColor(isEnabled ? Win98Color.darkText : Win98Color.disabledText)
            }
            .frame(width: 40, height: 34)
            .background(Win98Color.buttonFace)
            .modifier(BevelModifier(style: isPressed ? .sunken : .raised))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Menu Item
struct Win98MenuItem: View {
    let title: String
    let shortcut: String?
    let hasSubmenu: Bool
    let isEnabled: Bool
    let isSeparator: Bool
    let action: () -> Void

    init(title: String, shortcut: String? = nil, hasSubmenu: Bool = false,
         isEnabled: Bool = true, isSeparator: Bool = false, action: @escaping () -> Void = {}) {
        self.title = title
        self.shortcut = shortcut
        self.hasSubmenu = hasSubmenu
        self.isEnabled = isEnabled
        self.isSeparator = isSeparator
        self.action = action
    }

    @State private var isHovered = false

    var body: some View {
        if isSeparator {
            Divider()
                .background(Win98Color.buttonShadow)
                .padding(.vertical, 2)
        } else {
            Button(action: action) {
                HStack(spacing: 0) {
                    Text(title)
                        .font(Win98Font.menu)
                        .foregroundColor(isEnabled ? (isHovered ? Win98Color.titleText : Win98Color.darkText) : Win98Color.disabledText)
                        .padding(.leading, 20)
                    Spacer()
                    if let sc = shortcut {
                        Text(sc)
                            .font(Win98Font.menu)
                            .foregroundColor(isEnabled ? (isHovered ? Win98Color.titleText : Win98Color.darkText) : Win98Color.disabledText)
                            .padding(.trailing, hasSubmenu ? 16 : 8)
                    }
                    if hasSubmenu {
                        Text("▶")
                            .font(.system(size: 8))
                            .foregroundColor(isEnabled ? (isHovered ? Win98Color.titleText : Win98Color.darkText) : Win98Color.disabledText)
                            .padding(.trailing, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: Win98Metrics.menuItemHeight)
                .background(isHovered ? Win98Color.selectionBackground : Color.clear)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!isEnabled)
            .onHover { h in isHovered = h }
        }
    }
}
