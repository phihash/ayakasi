import SwiftUI
import WebKit
import os

struct WebView: UIViewRepresentable {
    var url : URL?

    class Coordinator: NSObject, WKNavigationDelegate {
        // 証明書エラーの握りつぶし（旧didReceive challenge）は削除。OS標準の検証に任せる。

        // 読み込み中は真っ白なだけで、開けていないように見えるため
        let spinner = UIActivityIndicatorView(style: .large)

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            spinner.stopAnimating()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            spinner.stopAnimating()
            Logger.web.error("読み込み失敗: \(String(describing: error))")
        }

        // 通信できないときはdidFailではなくこちらが呼ばれる
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            spinner.stopAnimating()
            Logger.web.error("読み込み失敗: \(String(describing: error))")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator

        let spinner = context.coordinator.spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
        ])
        spinner.startAnimating()

        // updateUIViewで読み込まないのは、SwiftUIの再描画のたびにページが読み込み直されるため
        if let url {
            webView.load(URLRequest(url: url))
        } else {
            spinner.stopAnimating()
            Logger.web.error("URLがnilのため読み込みできない")
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

