import Foundation
import FeedKit

@MainActor
class NewsService: ObservableObject {
    @Published var items: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let newsSources = [
        "妖怪":"https://www.google.co.jp/alerts/feeds/14350951871509070518/8255054665312320913",
        "イベント":"https://www.google.co.jp/alerts/feeds/14350951871509070518/14131475351883460019",
        "河童":"https://www.google.co.jp/alerts/feeds/14350951871509070518/13120840386550034680",
        "雪女":"https://www.google.co.jp/alerts/feeds/14350951871509070518/3735127170972070277",
    ]
    
    func fetchFeed(for category: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let urlString = newsSources[category] ?? (newsSources["妖怪"] ?? "")
            let atom = try await AtomFeed(urlString: urlString)
            let entries = atom.entries ?? []
            
            var seenTitles = Set<Substring>()
            
            self.items = entries.compactMap { e in
                let title = (e.title ?? "")
                let titlePrefix = title.prefix(8)
                if seenTitles.contains(titlePrefix) { return nil }
                seenTitles.insert(titlePrefix)
                let href =
                (e.links?.first { $0.attributes?.rel == "alternate" }?.attributes?.href)
                ?? e.links?.first?.attributes?.href
                
                let url = href.flatMap(URL.init(string:))
                
                let published = e.published ?? Date()
                return NewsItem(title: title.isEmpty ? "(無題)" : title, link: url, published: published)
            }
        } catch {
            self.errorMessage = "読み込みに失敗しました: \(error.localizedDescription)"
        }
    }
}