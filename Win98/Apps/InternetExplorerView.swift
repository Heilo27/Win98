import SwiftUI
import WebKit

// MARK: - Internet Explorer 5 — real WebKit browser with Win98 chrome
struct InternetExplorerView: View {
    @State private var urlText: String = "https://www.google.com"
    @State private var committedURL: URL = URL(string: "https://www.google.com")!
    @State private var isLoading: Bool = false
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var pageTitle: String = ""
    @State private var progress: Double = 0
    @State private var webViewRef: WKWebView? = nil
    @State private var showFavorites: Bool = false
    @State private var showFileMenu: Bool = false

    let favorites: [(String, String)] = [
        ("MSN.com", "https://www.msn.com"),
        ("Google", "https://www.google.com"),
        ("Wikipedia", "https://en.wikipedia.org"),
        ("The Old Net", "https://theoldnet.com"),
        ("Cameron's World", "https://www.cameronsworld.net"),
        ("Wiby — Old Web Search", "https://wiby.me"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // IE Menu bar
            ieMenuBar

            // IE Toolbar (buttons row)
            ieToolbar

            // Address bar
            ieAddressBar

            // Progress bar (thin, blue, under address bar — Win98 IE style)
            if isLoading {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Win98Color.buttonFace
                        Rectangle()
                            .fill(Color(hex: "#000080"))
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 3)
            }

            // Web content
            Win98WebView(
                url: committedURL,
                urlText: $urlText,
                isLoading: $isLoading,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                pageTitle: $pageTitle,
                progress: $progress,
                webViewRef: $webViewRef
            )

            // Status bar
            HStack(spacing: 0) {
                // Left status zone (loading text)
                HStack {
                    Text(isLoading ? "Opening page \(committedURL.host ?? "")..." : "Done")
                        .font(Win98Font.small)
                        .foregroundColor(Win98Color.darkText)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
                .modifier(SunkenBevel())
                .frame(height: 18)

                // Security zone
                Text("Internet")
                    .font(Win98Font.small)
                    .foregroundColor(Win98Color.darkText)
                    .padding(.horizontal, 6)
                    .modifier(SunkenBevel())
                    .frame(height: 18)
            }
            .frame(height: 20)
            .background(Win98Color.buttonFace)
        }
        .background(Win98Color.buttonFace)
        .overlay(
            Group {
                if showFavorites {
                    Color.clear.contentShape(Rectangle()).onTapGesture { showFavorites = false }
                    favoritesMenu
                }
                if showFileMenu {
                    Color.clear.contentShape(Rectangle()).onTapGesture { showFileMenu = false }
                    fileMenuView
                }
            }
        )
    }

    // MARK: - Menu Bar
    var ieMenuBar: some View {
        HStack(spacing: 0) {
            menuBarItem("File") { showFileMenu.toggle(); showFavorites = false }
            menuBarItem("Edit") {}
            menuBarItem("View") {}
            menuBarItem("Favorites") { showFavorites.toggle(); showFileMenu = false }
            menuBarItem("Tools") {}
            menuBarItem("Help") {}
            Spacer()
        }
        .frame(height: 20)
        .background(Win98Color.buttonFace)
    }

    func menuBarItem(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Win98Font.menu)
                .foregroundColor(Win98Color.darkText)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar
    var ieToolbar: some View {
        HStack(spacing: 1) {
            ieToolbarButton("◀", enabled: canGoBack) { webViewRef?.goBack() }
            ieToolbarButton("▶", enabled: canGoForward) { webViewRef?.goForward() }
            ieToolbarButton("✕", enabled: isLoading) { webViewRef?.stopLoading() }
            ieToolbarButton("↺", enabled: true) { webViewRef?.reload() }

            Divider().frame(height: 20).padding(.horizontal, 2)

            ieToolbarButton("⌂", enabled: true) { navigate(to: "https://www.msn.com") }

            Divider().frame(height: 20).padding(.horizontal, 2)

            ieToolbarButton("⭐", enabled: true) { showFavorites.toggle() }

            Spacer()
        }
        .frame(height: 30)
        .padding(.horizontal, 4)
        .background(Win98Color.buttonFace)
        .overlay(Divider(), alignment: .bottom)
    }

    func ieToolbarButton(_ glyph: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(glyph)
                .font(.system(size: 14))
                .frame(width: 28, height: 24)
                .foregroundColor(enabled ? Win98Color.darkText : Win98Color.disabledText)
        }
        .buttonStyle(Win98ToolbarButtonStyle(enabled: enabled))
        .disabled(!enabled)
    }

    // MARK: - Address Bar
    var ieAddressBar: some View {
        HStack(spacing: 4) {
            Text("Address")
                .font(Win98Font.small)
                .foregroundColor(Win98Color.darkText)
                .padding(.leading, 4)

            HStack(spacing: 0) {
                // Globe icon
                Text("🌐")
                    .font(.system(size: 11))
                    .padding(.leading, 2)

                TextField("", text: $urlText)
                    .font(Win98Font.system(11))
                    .foregroundColor(Win98Color.darkText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 4)
                    .onSubmit { navigate(to: urlText) }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }
            .frame(height: 20)
            .background(Win98Color.windowBackground)
            .modifier(SunkenBevel())

            Button("Go") { navigate(to: urlText) }
                .buttonStyle(Win98ButtonStyle())
                .frame(width: 36, height: 22)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(Win98Color.buttonFace)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Favorites dropdown
    var favoritesMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(favorites, id: \.0) { name, url in
                Button(action: {
                    navigate(to: url)
                    showFavorites = false
                }) {
                    HStack {
                        Text("🌐")
                            .font(.system(size: 10))
                        Text(name)
                            .font(Win98Font.menu)
                            .foregroundColor(Win98Color.darkText)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.clear)
                }
                .buttonStyle(.plain)
                .hoverHighlight()
            }
        }
        .background(Win98Color.windowBackground)
        .overlay(Rectangle().stroke(Win98Color.buttonDarkShadow, lineWidth: 1))
        .frame(width: 220)
        .shadow(radius: 2)
        .position(x: 130, y: 60)
    }

    // MARK: - File menu
    var fileMenuView: some View {
        VStack(alignment: .leading, spacing: 0) {
            menuItem("New Window") {}
            menuItem("Open...") {}
            menuItem("Save As...") {}
            Divider().padding(.vertical, 2)
            menuItem("Print...") {}
            Divider().padding(.vertical, 2)
            menuItem("Close") {}
        }
        .background(Win98Color.windowBackground)
        .overlay(Rectangle().stroke(Win98Color.buttonDarkShadow, lineWidth: 1))
        .frame(width: 160)
        .shadow(radius: 2)
        .position(x: 40, y: 60)
    }

    func menuItem(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: { action(); showFileMenu = false }) {
            HStack {
                Text(title)
                    .font(Win98Font.menu)
                    .foregroundColor(Win98Color.darkText)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .hoverHighlight()
    }

    // MARK: - Navigation
    func navigate(to urlString: String) {
        var raw = urlString.trimmingCharacters(in: .whitespaces)
        // If no scheme, assume https
        if !raw.hasPrefix("http://") && !raw.hasPrefix("https://") {
            // Could be a search query or bare domain
            if raw.contains(".") && !raw.contains(" ") {
                raw = "https://" + raw
            } else {
                // Treat as Google search
                let query = raw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? raw
                raw = "https://www.google.com/search?q=\(query)"
            }
        }
        guard let url = URL(string: raw) else { return }
        committedURL = url
        urlText = raw
    }
}

// MARK: - WKWebView wrapper
struct Win98WebView: UIViewRepresentable {
    let url: URL
    @Binding var urlText: String
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var pageTitle: String
    @Binding var progress: Double
    @Binding var webViewRef: WKWebView?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.addObserver(context.coordinator, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: "canGoBack", options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: "canGoForward", options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: "title", options: .new, context: nil)
        webView.allowsBackForwardNavigationGestures = true
        DispatchQueue.main.async { webViewRef = webView }
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only navigate if the URL actually changed
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: Win98WebView
        init(_ parent: Win98WebView) { self.parent = parent }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard let webView = object as? WKWebView else { return }
            DispatchQueue.main.async {
                switch keyPath {
                case "estimatedProgress": self.parent.progress = webView.estimatedProgress
                case "canGoBack": self.parent.canGoBack = webView.canGoBack
                case "canGoForward": self.parent.canGoForward = webView.canGoForward
                case "title": self.parent.pageTitle = webView.title ?? ""
                default: break
                }
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async { self.parent.isLoading = true }
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                if let urlStr = webView.url?.absoluteString {
                    self.parent.urlText = urlStr
                }
            }
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }
    }
}

// MARK: - Hover highlight helper
extension View {
    func hoverHighlight() -> some View {
        self.modifier(HoverHighlightModifier())
    }
}

struct HoverHighlightModifier: ViewModifier {
    @State private var isPressed = false
    func body(content: Content) -> some View {
        content
            .background(isPressed ? Win98Color.selectionBackground : Color.clear)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Sunken bevel for address bar / status zones
struct SunkenBevel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    // Top-left dark shadow (sunken)
                    VStack(spacing: 0) {
                        Rectangle().fill(Win98Color.buttonShadow).frame(height: 1)
                        HStack(spacing: 0) {
                            Rectangle().fill(Win98Color.buttonShadow).frame(width: 1)
                            Spacer()
                        }
                        Spacer()
                    }
                    // Bottom-right highlight
                    VStack(spacing: 0) {
                        Spacer()
                        HStack(spacing: 0) {
                            Spacer()
                            Rectangle().fill(Win98Color.buttonHighlight).frame(width: 1)
                        }
                        Rectangle().fill(Win98Color.buttonHighlight).frame(height: 1)
                    }
                }
            )
    }
}

// MARK: - Toolbar button style
struct Win98ToolbarButtonStyle: ButtonStyle {
    let enabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed && enabled
                    ? Win98Color.buttonFace.opacity(0.7)
                    : Win98Color.buttonFace
            )
            .overlay(
                configuration.isPressed && enabled
                ? AnyView(RoundedRectangle(cornerRadius: 0).stroke(Win98Color.buttonShadow, lineWidth: 1))
                : AnyView(EmptyView())
            )
    }
}
