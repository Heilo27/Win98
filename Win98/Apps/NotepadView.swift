import SwiftUI

// MARK: - Notepad
struct NotepadView: View {
    @State private var text: String = ""
    @State private var wordWrap: Bool = true
    @State private var showFindSheet: Bool = false
    @State private var findText: String = ""
    @State private var showUnsavedAlert: Bool = false
    @State private var fileName: String = "Untitled"
    @State private var isDirty: Bool = false
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        VStack(spacing: 0) {
            // Menu bar
            Win98MenuBar(items: [
                ("File", [
                    Win98MenuBarItem("New") {
                        if isDirty {
                            showUnsavedAlert = true
                        } else {
                            text = ""
                            fileName = "Untitled"
                        }
                    },
                    Win98MenuBarItem("Open...", shortcut: "Ctrl+O") { openFile() },
                    Win98MenuBarItem("Save", shortcut: "Ctrl+S") { saveFile() },
                    Win98MenuBarItem("Save As...") { saveFileAs() },
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Page Setup...") {},
                    Win98MenuBarItem("Print...", shortcut: "Ctrl+P", isEnabled: false) {},
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Exit") {},
                ]),
                ("Edit", [
                    Win98MenuBarItem("Undo", shortcut: "Ctrl+Z", isEnabled: false) {},
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Cut", shortcut: "Ctrl+X", isEnabled: !text.isEmpty) {},
                    Win98MenuBarItem("Copy", shortcut: "Ctrl+C", isEnabled: !text.isEmpty) {},
                    Win98MenuBarItem("Paste", shortcut: "Ctrl+V") {},
                    Win98MenuBarItem("Delete", shortcut: "Del", isEnabled: !text.isEmpty) {
                        text = ""
                        isDirty = true
                    },
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Select All", shortcut: "Ctrl+A") {},
                    Win98MenuBarItem("Time/Date", shortcut: "F5") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "h:mm a M/d/yyyy"
                        text += formatter.string(from: Date())
                        isDirty = true
                    },
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("Word Wrap") {
                        wordWrap.toggle()
                    },
                ]),
                ("Search", [
                    Win98MenuBarItem("Find...", shortcut: "Ctrl+F") { showFindSheet = true },
                    Win98MenuBarItem("Find Next", shortcut: "F3", isEnabled: !findText.isEmpty) {
                        // Find next occurrence
                    },
                ]),
                ("Help", [
                    Win98MenuBarItem("Help Topics") {},
                    Win98MenuBarItem(_sep: true),
                    Win98MenuBarItem("About Notepad") {},
                ]),
            ])

            // Text area
            TextEditor(text: Binding(
                get: { text },
                set: { text = $0; isDirty = true }
            ))
            .font(Font.custom("Menlo", size: 12))
            .foregroundColor(.black)
            .background(Win98Color.windowBackground)
            .scrollContentBackground(.hidden)
            .lineLimit(wordWrap ? nil : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Win98Color.windowBackground)
            .win98Well()
            .padding(2)
        }
        .background(Win98Color.windowBackground)
        .alert("Notepad", isPresented: $showUnsavedAlert) {
            Button("Save") { saveFile(); text = ""; fileName = "Untitled" }
            Button("Don't Save") { text = ""; fileName = "Untitled"; isDirty = false }
            Button("Cancel") {}
        } message: {
            Text("The text in \(fileName) has changed.\n\nDo you want to save the changes?")
        }
        .sheet(isPresented: $showFindSheet) {
            FindDialog(findText: $findText, text: $text)
        }
    }

    private func openFile() {
        // iOS file picker would go here
        // For now, load a sample
        text = "This is a sample document.\r\nYou can type here.\r\n\r\nNotepad - Windows 98"
        fileName = "sample.txt"
        isDirty = false
    }

    private func saveFile() {
        // Save implementation
        isDirty = false
    }

    private func saveFileAs() {
        isDirty = false
    }
}

// MARK: - Find Dialog
struct FindDialog: View {
    @Binding var findText: String
    @Binding var text: String
    @Environment(\.dismiss) var dismiss
    @State private var matchCase: Bool = false
    @State private var direction: Int = 1

    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("Find")
                    .font(Win98Font.title)
                    .foregroundColor(Win98Color.titleText)
                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(height: Win98Metrics.titleBarHeight)
            .background(LinearGradient(colors: [Win98Color.activeTitleLeft, Win98Color.activeTitleRight],
                                       startPoint: .leading, endPoint: .trailing))

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Find what:")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.darkText)
                        .frame(width: 70, alignment: .leading)
                    TextField("", text: $findText)
                        .font(Font.custom("Menlo", size: 12))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 4)
                        .frame(height: 22)
                        .background(Win98Color.windowBackground)
                        .win98Well()
                        .frame(width: 150)
                }

                HStack {
                    Toggle("Match case", isOn: $matchCase)
                        .font(Win98Font.ui)
                        .toggleStyle(Win98CheckboxStyle())
                    Spacer()
                }

                HStack {
                    Text("Direction:")
                        .font(Win98Font.ui)
                        .foregroundColor(Win98Color.darkText)
                    Picker("Direction", selection: $direction) {
                        Text("Up").tag(0)
                        Text("Down").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 120)
                }

                HStack {
                    Spacer()
                    Win98Button(title: "Find Next") {}
                    Win98Button(title: "Cancel") { dismiss() }
                    Win98Button(title: "Help") {}
                }
            }
            .padding(16)
            .background(Win98Color.buttonFace)
        }
        .frame(width: 320)
        .win98Raised()
        .background(Win98Color.buttonFace)
    }
}

// MARK: - Win98 Checkbox Style
struct Win98CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            ZStack {
                Rectangle()
                    .fill(Win98Color.windowBackground)
                    .frame(width: 13, height: 13)
                    .win98Well()
                if configuration.isOn {
                    Text("✓")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Win98Color.darkText)
                }
            }
            configuration.label
                .font(Win98Font.ui)
                .foregroundColor(Win98Color.darkText)
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}
