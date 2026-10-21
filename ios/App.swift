import SwiftUI
import WebKit
import UniformTypeIdentifiers

@main
struct PureFluidDynamicsApp: App {
    var body: some Scene {
        WindowGroup {
            FluidWebView()
                .ignoresSafeArea()
                .background(Color(red: 7 / 255, green: 9 / 255, blue: 12 / 255))
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}

/// Serves the bundled web app from app://local/ so it has a stable origin (storage, workers) and runs fully offline.
final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {
    private let root = Bundle.main.resourceURL!.appendingPathComponent("web", isDirectory: true)

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url else { return }
        var path = url.path
        if path.isEmpty || path == "/" { path = "/index.html" }
        let file = root.appendingPathComponent(String(path.dropFirst())).standardizedFileURL
        guard file.path.hasPrefix(root.standardizedFileURL.path), let data = try? Data(contentsOf: file) else {
            task.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        let mime = UTType(filenameExtension: file.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1",
                                       headerFields: ["Content-Type": mime, "Content-Length": "\(data.count)", "Cache-Control": "no-cache"])!
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
}

struct FluidWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(BundleSchemeHandler(), forURLScheme: "app")
        config.userContentController.add(context.coordinator, name: "native")
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()

        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = UIColor(red: 7 / 255, green: 9 / 255, blue: 12 / 255, alpha: 1)
        web.scrollView.backgroundColor = web.backgroundColor
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.allowsLinkPreview = false
        web.navigationDelegate = context.coordinator
        web.uiDelegate = context.coordinator
        context.coordinator.webView = web
        web.load(URLRequest(url: URL(string: "app://local/index.html")!))
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
        weak var webView: WKWebView?

        // Messages from the page: save a file through the share sheet, or copy text.
        func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
            switch type {
            case "copy":
                UIPasteboard.general.string = body["text"] as? String
            case "file":
                guard let name = body["name"] as? String, let b64 = body["data"] as? String,
                      let data = Data(base64Encoded: b64) else { return }
                let safe = name.replacingOccurrences(of: "/", with: "-")
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(safe)
                do { try data.write(to: url, options: .atomic) } catch { return }
                DispatchQueue.main.async { self.share(url) }
            default:
                break
            }
        }

        private func share(_ url: URL) {
            guard let web = webView, let root = web.window?.rootViewController else { return }
            var top = root
            while let next = top.presentedViewController { top = next }
            let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let pop = sheet.popoverPresentationController {
                pop.sourceView = web
                pop.sourceRect = CGRect(x: web.bounds.midX, y: web.bounds.maxY - 80, width: 1, height: 1)
                pop.permittedArrowDirections = .down
            }
            top.present(sheet, animated: true)
        }

        // Keep the app on its bundled page; open any web link in Safari.
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = action.request.url, let scheme = url.scheme, scheme == "http" || scheme == "https" || scheme == "mailto" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = action.request.url { UIApplication.shared.open(url) }
            return nil
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }
    }
}
