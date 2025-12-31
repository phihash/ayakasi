import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url : URL?
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            // SSL証明書エラーを許可
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("🚀 WebView started loading")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView finished loading")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed loading: \(error)")
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
           print("🌐 WebView loading URL: \(url)")
           let request = URLRequest(url: url)
            webView.load(request)
        } else {
            print("❌ WebView: URL is nil")
        }
    }
}

