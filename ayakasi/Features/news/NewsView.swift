import SwiftUI

let publishedFormatter : DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ja_JP")
    f.dateStyle = .long
    f.timeStyle = .short
    return f
}()

struct NewsView : View{
    @StateObject private var newsService = NewsService()
    @State private var selectedNewsUrl: URL?
    var selectedNew : String
    
    var body : some View{
        ZStack{
            if newsService.isLoading {
                ProgressView("読み込み中…")
                    .frame(height: 320)
                
            } else if let msg = newsService.errorMessage {
                Text(msg)
            }else{
                VStack(alignment: .leading, spacing: 16) {

                    ForEach(Array(newsService.items.indices), id: \.self) { index in
                        let item = newsService.items[index]
                        let title = item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                        if let url = item.link {
                            NewsListItem(
                                title: title,
                                published: item.published,
                                image: item.image,
                                phrases: item.phrases
                            ) {
                                selectedNewsUrl = url
                            }
                            .padding(.horizontal, 16)
                        } else {
                            Text("\(index + 1). \(title)")
                        }
                    }
                }
            }
        }
        .task(id: selectedNew) {
            await newsService.fetchFeed(for: selectedNew)
        }
        .refreshable{
            await newsService.fetchFeed(for: selectedNew)
        }
        .sheet(item: $selectedNewsUrl) { url in
            SafariView(url: url)
        }
    }
}
