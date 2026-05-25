import SwiftUI

// MARK: - Start Menu
struct StartMenuView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var activeSubmenu: String? = nil

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // Left banner
            ZStack {
                LinearGradient(
                    colors: [Win98Color.startMenuBannerTop, Win98Color.startMenuBannerBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Text("Windows 98")
                    .font(.custom("Menlo", size: 16).weight(.bold))
                    .foregroundColor(Win98Color.titleText.opacity(0.4))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 300)
            }
            .frame(width: 26, height: 400)

            // Menu items
            VStack(alignment: .leading, spacing: 0) {
                // Programs
                StartMenuItemRow(
                    title: "Programs",
                    icon: "folder.fill",
                    hasSubmenu: true,
                    isActive: activeSubmenu == "Programs"
                ) {
                    activeSubmenu = activeSubmenu == "Programs" ? nil : "Programs"
                }
                .overlay(
                    Group {
                        if activeSubmenu == "Programs" {
                            ProgramsSubmenu()
                                .offset(x: 175, y: -10)
                        }
                    },
                    alignment: .trailing
                )

                // Favorites
                StartMenuItemRow(title: "Favorites", icon: "star.fill", hasSubmenu: true, isActive: false) {
                    activeSubmenu = nil
                }

                // Documents
                StartMenuItemRow(title: "Documents", icon: "doc.fill", hasSubmenu: true, isActive: activeSubmenu == "Documents") {
                    activeSubmenu = activeSubmenu == "Documents" ? nil : "Documents"
                }

                // Settings
                StartMenuItemRow(title: "Settings", icon: "gearshape.fill", hasSubmenu: true, isActive: activeSubmenu == "Settings") {
                    activeSubmenu = activeSubmenu == "Settings" ? nil : "Settings"
                }
                .overlay(
                    Group {
                        if activeSubmenu == "Settings" {
                            SettingsSubmenu()
                                .offset(x: 175, y: -10)
                        }
                    },
                    alignment: .trailing
                )

                // Find
                StartMenuItemRow(title: "Find", icon: "magnifyingglass", hasSubmenu: true, isActive: false) {
                    activeSubmenu = nil
                }

                // Help
                StartMenuItemRow(title: "Help", icon: "questionmark.circle.fill", hasSubmenu: false, isActive: false) {
                    activeSubmenu = nil
                    windowManager.showStartMenu = false
                }

                // Run
                StartMenuItemRow(title: "Run...", icon: "terminal.fill", hasSubmenu: false, isActive: false) {
                    activeSubmenu = nil
                    windowManager.showStartMenu = false
                }

                // Separator
                menuSeparator

                // Log Off
                StartMenuItemRow(title: "Log Off User...", icon: "person.fill", hasSubmenu: false, isActive: false) {
                    activeSubmenu = nil
                    windowManager.showStartMenu = false
                }

                // Shut Down
                StartMenuItemRow(title: "Shut Down...", icon: "power", hasSubmenu: false, isActive: false) {
                    activeSubmenu = nil
                    windowManager.showStartMenu = false
                    windowManager.showShutDownDialog = true
                }
            }
            .frame(width: 176)
            .background(Win98Color.buttonFace)
        }
        .frame(width: 202, height: 400)
        .background(Win98Color.buttonFace)
        .win98Raised()
        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
    }

    var menuSeparator: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Win98Color.buttonShadow)
                .frame(height: 1)
            Rectangle()
                .fill(Win98Color.buttonHighlight)
                .frame(height: 1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

// MARK: - Start Menu Item Row
struct StartMenuItemRow: View {
    let title: String
    let icon: String
    let hasSubmenu: Bool
    let isActive: Bool
    let action: () -> Void
    @State private var isHovered: Bool = false

    var highlighted: Bool { isHovered || isActive }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(highlighted ? Win98Color.titleText : Win98Color.darkText)
                    .frame(width: 20)
                Text(title)
                    .font(Win98Font.menu)
                    .foregroundColor(highlighted ? Win98Color.titleText : Win98Color.darkText)
                Spacer()
                if hasSubmenu {
                    Text("▶")
                        .font(.system(size: 8))
                        .foregroundColor(highlighted ? Win98Color.titleText : Win98Color.darkText)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 26)
            .frame(maxWidth: .infinity)
            .background(highlighted ? Win98Color.selectionBackground : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { h in isHovered = h }
    }
}

// MARK: - Programs Submenu
struct ProgramsSubmenu: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var activeSubmenu: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            submenuItem("Accessories", hasSubmenu: true, active: activeSubmenu == "Accessories") {
                activeSubmenu = activeSubmenu == "Accessories" ? nil : "Accessories"
            }
            .overlay(
                Group {
                    if activeSubmenu == "Accessories" {
                        AccessoriesSubmenu()
                            .offset(x: 150, y: -10)
                    }
                },
                alignment: .trailing
            )

            submenuItem("Internet Explorer", hasSubmenu: false, active: false) {
                windowManager.openApp(.internetExplorer, screenSize: windowManager.screenSize)
                windowManager.showStartMenu = false
            }

            submenuItem("Outlook Express", hasSubmenu: false, active: false) {
                windowManager.showStartMenu = false
            }

            submenuItem("Windows Explorer", hasSubmenu: false, active: false) {
                windowManager.openApp(.explorer, screenSize: windowManager.screenSize)
                windowManager.showStartMenu = false
            }
        }
        .frame(width: 160)
        .background(Win98Color.buttonFace)
        .win98Raised()
        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
    }

    @ViewBuilder
    func submenuItem(_ title: String, hasSubmenu: Bool, active: Bool, action: @escaping () -> Void) -> some View {
        StartMenuItemRow(title: title, icon: "folder", hasSubmenu: hasSubmenu, isActive: active, action: action)
    }
}

// MARK: - Accessories Submenu
struct AccessoriesSubmenu: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var activeSubmenu: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            submenuItem("Games", hasSubmenu: true, active: activeSubmenu == "Games") {
                activeSubmenu = activeSubmenu == "Games" ? nil : "Games"
            }
            .overlay(
                Group {
                    if activeSubmenu == "Games" {
                        GamesSubmenu()
                            .offset(x: 150, y: -10)
                    }
                },
                alignment: .trailing
            )

            menuSep

            submenuItem("Calculator", hasSubmenu: false, active: false) {
                windowManager.openApp(.calculator, screenSize: windowManager.screenSize)
                windowManager.showStartMenu = false
            }
            submenuItem("Notepad", hasSubmenu: false, active: false) {
                windowManager.openApp(.notepad, screenSize: windowManager.screenSize)
                windowManager.showStartMenu = false
            }
            submenuItem("Paint", hasSubmenu: false, active: false) {
                windowManager.showStartMenu = false
            }
            submenuItem("WordPad", hasSubmenu: false, active: false) {
                windowManager.showStartMenu = false
            }
        }
        .frame(width: 150)
        .background(Win98Color.buttonFace)
        .win98Raised()
        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
    }

    var menuSep: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Win98Color.buttonShadow).frame(height: 1)
            Rectangle().fill(Win98Color.buttonHighlight).frame(height: 1)
        }
        .padding(.horizontal, 4).padding(.vertical, 2)
    }

    @ViewBuilder
    func submenuItem(_ title: String, hasSubmenu: Bool, active: Bool, action: @escaping () -> Void) -> some View {
        StartMenuItemRow(title: title, icon: "folder", hasSubmenu: hasSubmenu, isActive: active, action: action)
    }
}

// MARK: - Games Submenu
struct GamesSubmenu: View {
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            gameItem("Minesweeper", app: .minesweeper)
            gameItem("Solitaire", app: .solitaire)
            gameItem("FreeCell") {}
            gameItem("Hearts") {}
        }
        .frame(width: 140)
        .background(Win98Color.buttonFace)
        .win98Raised()
        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
    }

    @ViewBuilder
    func gameItem(_ title: String, app: Win98AppType? = nil, action: @escaping () -> Void = {}) -> some View {
        StartMenuItemRow(title: title, icon: "gamecontroller", hasSubmenu: false, isActive: false) {
            if let app = app {
                windowManager.openApp(app, screenSize: windowManager.screenSize)
            } else {
                action()
            }
            windowManager.showStartMenu = false
        }
    }
}

// MARK: - Settings Submenu
struct SettingsSubmenu: View {
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StartMenuItemRow(title: "Control Panel", icon: "gearshape.2", hasSubmenu: false, isActive: false) {
                windowManager.openApp(.myComputer, screenSize: windowManager.screenSize)
                windowManager.showStartMenu = false
            }
            StartMenuItemRow(title: "Printers", icon: "printer", hasSubmenu: false, isActive: false) {
                windowManager.showStartMenu = false
            }
            StartMenuItemRow(title: "Taskbar & Start Menu", icon: "dock.rectangle", hasSubmenu: false, isActive: false) {
                windowManager.showStartMenu = false
            }
            StartMenuItemRow(title: "Folder Options", icon: "folder.badge.gearshape", hasSubmenu: false, isActive: false) {
                windowManager.showStartMenu = false
            }
        }
        .frame(width: 175)
        .background(Win98Color.buttonFace)
        .win98Raised()
        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
    }
}
