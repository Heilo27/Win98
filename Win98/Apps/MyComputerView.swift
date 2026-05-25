import SwiftUI

// MARK: - My Computer
struct MyComputerView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var selectedItem: String? = nil
    @State private var showCDrive: Bool = false

    let items: [(String, AnyView, String)] = [
        ("3½ Floppy (A:)", AnyView(FloppyDriveIcon(size: 32)), "3½-Inch Floppy Disk"),
        ("Local Disk (C:)", AnyView(HardDriveIcon(size: 32)), "Local Disk"),
        ("CD-ROM (D:)", AnyView(CDROMIcon(size: 32)), "Compact Disc"),
        ("Control Panel", AnyView(ControlPanelIcon(size: 32)), "System Folder"),
        ("Printers", AnyView(PrintersIcon(size: 32)), "System Folder"),
        ("Dial-Up Networking", AnyView(NetworkNeighborhoodIcon(size: 32)), "System Folder"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Menu bar
            Win98MenuBar(items: [
                ("File", [
                    Win98MenuBarItem("Properties") {},
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Close") {},
                ]),
                ("Edit", [
                    Win98MenuBarItem("Select All", shortcut: "Ctrl+A") {},
                    Win98MenuBarItem("Invert Selection") {},
                ]),
                ("View", [
                    Win98MenuBarItem("Toolbar") {},
                    Win98MenuBarItem("Status Bar") {},
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Large Icons") {},
                    Win98MenuBarItem("Small Icons") {},
                    Win98MenuBarItem("List") {},
                    Win98MenuBarItem("Details") {},
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Refresh") {},
                ]),
                ("Help", [
                    Win98MenuBarItem("Help Topics") {},
                    Win98MenuBarItem("About Windows") {},
                ]),
            ])

            // Toolbar
            HStack(spacing: 2) {
                Win98ToolbarButton(iconName: "chevron.left", label: "Back", action: {}, isEnabled: false)
                Win98ToolbarButton(iconName: "chevron.right", label: "Forward", action: {}, isEnabled: false)
                Win98ToolbarButton(iconName: "chevron.up", label: "Up", action: {}, isEnabled: false)
                Rectangle()
                    .fill(Win98Color.buttonShadow)
                    .frame(width: 1, height: 28)
                    .padding(.horizontal, 2)
                Win98ToolbarButton(iconName: "scissors", label: "Cut", action: {}, isEnabled: selectedItem != nil)
                Win98ToolbarButton(iconName: "doc.on.doc", label: "Copy", action: {}, isEnabled: selectedItem != nil)
                Win98ToolbarButton(iconName: "doc.on.clipboard", label: "Paste", action: {})
                Rectangle()
                    .fill(Win98Color.buttonShadow)
                    .frame(width: 1, height: 28)
                    .padding(.horizontal, 2)
                // Address bar
                HStack(spacing: 4) {
                    Text("Address")
                        .font(Win98Font.small)
                        .foregroundColor(Win98Color.darkText)
                    HStack(spacing: 2) {
                        MyComputerIcon(size: 14)
                        Text("My Computer")
                            .font(Win98Font.ui)
                            .foregroundColor(Win98Color.darkText)
                        Spacer()
                        Text("▼")
                            .font(.system(size: 8))
                            .foregroundColor(Win98Color.darkText)
                            .padding(.trailing, 2)
                    }
                    .padding(.horizontal, 4)
                    .frame(height: 20)
                    .frame(maxWidth: .infinity)
                    .background(Win98Color.windowBackground)
                    .win98Well()
                }
                .padding(.horizontal, 4)
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(Win98Color.buttonFace)
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(Win98Color.buttonShadow),
                alignment: .bottom
            )

            // Content area - icons grid
            if showCDrive {
                CDriveView(onBack: { showCDrive = false })
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                        ForEach(items, id: \.0) { item in
                            MyComputerIconItem(
                                label: item.0,
                                icon: item.1,
                                isSelected: selectedItem == item.0
                            ) {
                                selectedItem = item.0
                            } onDoubleClick: {
                                if item.0 == "Local Disk (C:)" {
                                    showCDrive = true
                                }
                            }
                        }
                    }
                    .padding(12)
                }
                .background(Win98Color.windowBackground)
            }

            // Status bar
            Win98StatusBar(text: "\(items.count) object(s)")
        }
    }
}

// MARK: - My Computer Icon Item
struct MyComputerIconItem: View {
    let label: String
    let icon: AnyView
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Win98Color.selectionBackground)
                        .frame(width: 36, height: 36)
                }
                icon
                    .frame(width: 32, height: 32)
                    .colorMultiply(isSelected ? Color(hex: "#6060FF") : .white)
            }

            Text(label)
                .font(Win98Font.small)
                .foregroundColor(isSelected ? Win98Color.titleText : Win98Color.darkText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 2)
                .padding(.vertical, 1)
                .background(isSelected ? Win98Color.selectionBackground : Color.clear)
                .frame(maxWidth: 80)
        }
        .frame(width: 80, height: 68)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { onDoubleClick() }
        .onTapGesture(count: 1) { onSelect() }
    }
}

// MARK: - C: Drive Explorer
struct CDriveView: View {
    let onBack: () -> Void
    @State private var selectedFile: String? = nil

    let files: [(String, String, String)] = [
        ("Windows", "folder", "System Folder"),
        ("Program Files", "folder", "File Folder"),
        ("My Documents", "folder", "File Folder"),
        ("AUTOEXEC.BAT", "doc", "MS-DOS Batch File"),
        ("CONFIG.SYS", "doc", "System File"),
        ("IO.SYS", "doc", "System File"),
        ("MSDOS.SYS", "doc", "System File"),
        ("COMMAND.COM", "doc.text", "MS-DOS Application"),
        ("WIN.INI", "doc.text", "Configuration Settings"),
        ("SYSTEM.INI", "doc.text", "Configuration Settings"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Back button area
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .font(Win98Font.ui)
                    }
                    .foregroundColor(Win98Color.darkText)
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(Win98Color.buttonFace)
                    .win98Raised()
                }
                .buttonStyle(PlainButtonStyle())

                Text("C:\\")
                    .font(Win98Font.ui)
                    .foregroundColor(Win98Color.darkText)
                    .padding(.leading, 8)
                Spacer()
            }
            .padding(4)
            .background(Win98Color.buttonFace)
            .overlay(Rectangle().frame(height: 1).foregroundColor(Win98Color.buttonShadow), alignment: .bottom)

            // File list
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 0) {
                        headerCell("Name", width: 200)
                        headerCell("Type", width: 120)
                    }
                    .background(Win98Color.buttonFace)
                    .win98Raised()

                    ForEach(files, id: \.0) { file in
                        HStack(spacing: 0) {
                            HStack(spacing: 6) {
                                Image(systemName: file.1)
                                    .font(.system(size: 12))
                                    .foregroundColor(file.1 == "folder" ? Color(hex: "#FFCF00") : Win98Color.darkText)
                                Text(file.0)
                                    .font(Win98Font.ui)
                                    .foregroundColor(selectedFile == file.0 ? Win98Color.titleText : Win98Color.darkText)
                            }
                            .padding(.horizontal, 4)
                            .frame(width: 200, height: 20, alignment: .leading)

                            Text(file.2)
                                .font(Win98Font.ui)
                                .foregroundColor(selectedFile == file.0 ? Win98Color.titleText : Win98Color.darkText)
                                .frame(width: 120, height: 20, alignment: .leading)
                                .padding(.horizontal, 4)
                        }
                        .background(selectedFile == file.0 ? Win98Color.selectionBackground : Win98Color.windowBackground)
                        .contentShape(Rectangle())
                        .onTapGesture { selectedFile = file.0 }
                    }
                }
            }
            .background(Win98Color.windowBackground)

            Win98StatusBar(text: "\(files.count) object(s)")
        }
    }

    func headerCell(_ title: String, width: CGFloat) -> some View {
        Text(title)
            .font(Win98Font.ui)
            .foregroundColor(Win98Color.darkText)
            .frame(width: width, height: 20, alignment: .leading)
            .padding(.horizontal, 4)
    }
}
