import Foundation
import FeedKit

@MainActor
class NewsService: ObservableObject {
    @Published var items: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let yokaiFeedURL = "https://www.google.co.jp/alerts/feeds/14350951871509070518/8255054665312320913"
    
    func fetchFeed(for _: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let atom = try await AtomFeed(urlString: yokaiFeedURL)
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
