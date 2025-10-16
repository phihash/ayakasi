import Foundation

struct ReferenceLink: Identifiable{
    let id = UUID()
    let title: String
    let url: URL
}

struct Ayakasi : Identifiable {
    let id : UUID = UUID()
    let name : String
    let imageName : String
    let description: String
    let tags : [String]
    let categories : [String]
    var btw: String? = nil          // ← 追加：「ちなみに」用のメモ（別名・豆知識など）
    var episodes: String? = nil
    var references: [ReferenceLink]? = nil
}

struct NewsItem: Identifiable { let id = UUID(); let title: String; let link: URL?; let published: Date }
