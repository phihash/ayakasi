import SwiftUI
import WebKit
import os

struct WebView: UIViewRepresentable {
    var url : URL?

    class Coordinator: NSObject, WKNavigationDelegate {
        // 証明書エラーの握りつぶし（旧didReceive challenge）は削除。OS標準の検証に任せる。

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
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
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            webView.load(URLRequest(url: url))
        } else {
            Logger.web.error("URLがnilのため読み込みできない")
        }
    }
}

