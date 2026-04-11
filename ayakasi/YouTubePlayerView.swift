import WebKit
import SwiftUI

struct YouTubePlayerView: UIViewRepresentable {
    let videoId: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
          <html>                                                                                                                                                                                               
          <body style="margin:0;padding:0;background:#000;">
          <iframe width="100%" height="100%"                                                                                                                                                                   
              src="https://www.youtube.com/embed/\(videoId)"                                                                                                                                                   
              frameborder="0"
              allowfullscreen>                                                                                                                                                                                 
          </iframe>                                                                                                                                                                                            
          </body>
          </html>                                                                                                                                                                                              
          """
        uiView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }
}
