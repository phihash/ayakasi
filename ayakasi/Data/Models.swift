import Foundation

struct ReferenceLink: Identifiable{
    let id = UUID()
    let title: String
    let url: URL
}

struct Ayakasi : Identifiable {
    let id : UUID = UUID()
    let name : String
    let documentId: String  // Firestore用のドキュメントID
    let imageName : String
    let description: String
    let categories : [String]
    let relatedCategory: String?    // 関連カテゴリ（"すべて"以外の具体的なカテゴリ）
    var btw: String? = nil          // ← 追加：「ちなみに」用のメモ（別名・豆知識など）
    var references: [ReferenceLink]? = nil
    let sotry: Bool 
}

struct NewsItem: Identifiable { let id = UUID(); let title: String; let link: URL?; let published: Date }
