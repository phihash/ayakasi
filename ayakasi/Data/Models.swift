import Foundation

struct Ayakasi : Identifiable, Decodable {
    let id : UUID = UUID()
    let name : String
    let documentId: String  // Firestore用のドキュメントID
    let imageName : String
    var imageSource: String? = nil  // 画像の出典元
    var imageAuthor: String? = nil  // 画像の作者名
    var imageTitle: String? = nil   // 画像のタイトル
    let description: String
    let categories : [String]
    let relatedCategory: String?    // 関連カテゴリ（"すべて"以外の具体的なカテゴリ）
    var searchKeywords: [String]? = nil  // 検索用キーワード（読み仮名・別名など）
    let story: Bool

    // スポット情報（ゆかりの地） - 複数対応
    var relatedSpots: [YokaiSpot]? = nil

    var videoId: String? = nil  // YouTube動画ID

    private enum CodingKeys: String, CodingKey {
        case name, documentId, imageName, imageSource, imageAuthor, imageTitle
        case description, categories, relatedCategory, searchKeywords
        case story, relatedSpots, videoId
    }
}

// リモート配信用のトップレベル構造（data.json）
struct YokaiData: Decodable {
    let version: Int
    let yokai: [Ayakasi]
    let destinations: [YokaiDestination]?  // 地図の妖怪スポット(町・施設)。旧data.jsonには無い
}

extension Ayakasi: Hashable {
    static func == (lhs: Ayakasi, rhs: Ayakasi) -> Bool {
        lhs.documentId == rhs.documentId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(documentId)
    }
}

struct NewsItem: Identifiable { let id = UUID(); let title: String; let link: URL?; let published: Date }
