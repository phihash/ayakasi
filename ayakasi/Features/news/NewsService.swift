import Foundation

@MainActor
class NewsService: ObservableObject {
    @Published var items: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Workerが「タイトルに妖怪がある記事」だけに絞って返す。絞り込みの調整は審査なしでWorker側で行う
    private struct Entry: Decodable { let title: String; let link: String; let published: Date }

    func fetchFeed(for _: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: AppConstants.newsDataURL)!)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            items = try decoder.decode([Entry].self, from: data).map {
                NewsItem(title: $0.title, link: URL(string: $0.link), published: $0.published)
            }
        } catch {
            errorMessage = "読み込みに失敗しました: \(error.localizedDescription)"
        }
    }
}
