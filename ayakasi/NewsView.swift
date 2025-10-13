import SwiftUI
import Foundation
import FeedKit

@MainActor
struct NewsView: View {
    @State private var items: [NewsItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let feedURLString = "https://www.google.co.jp/alerts/feeds/14350951871509070518/8255054665312320913"
    
    private func fetchFeed() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
    
        do {
            let atom = try await AtomFeed(urlString: feedURLString)
            let entries = atom.entries ?? []
            print(entries)
            self.items = entries.compactMap { e in
                let title = (e.title ?? "")
    
                // rel="alternate" を優先、なければ先頭リンク
                let href =
                    (e.links?.first { $0.attributes?.rel == "alternate" }?.attributes?.href)
                    ?? e.links?.first?.attributes?.href
    
                let url = href.flatMap(URL.init(string:))
                return NewsItem(title: title.isEmpty ? "(無題)" : title, link: url)
            }
        } catch {
            self.errorMessage = "読み込みに失敗しました: \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        NavigationStack{
            Group{
                if isLoading {
                    ProgressView("読み込み中…")
                } else if let errorMessage {
                    Text(errorMessage)
                }else{
                    List(items){ item in
                        if let url = item.link {
                            Link(item.title, destination: url)
                        } else {
                            Text(item.title)
                        }
                    }
                }
            }
        }
        .task{
           await fetchFeed()
        }
        .refreshable{
           await  fetchFeed()
        }
    }
}

