import Foundation
import MapKit

enum MediaType: String {
    case novel = "小説"
    case manga = "漫画"
    case anime = "アニメ"
    case game = "ゲーム"
    case movie = "映画"
    case other = "その他"
}

struct MediaAppearance: Identifiable {
    let id = UUID()
    let title: String
    let type: [MediaType]
    let note: String?
}

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
    var imageSource: String? = nil  // 画像の出典元
    var imageAuthor: String? = nil  // 画像の作者名
    var imageTitle: String? = nil   // 画像のタイトル
    let description: String
    let categories : [String]
    let relatedCategory: String?    // 関連カテゴリ（"すべて"以外の具体的なカテゴリ）
    var references: [ReferenceLink]? = nil
    var searchKeywords: [String]? = nil  // 検索用キーワード（読み仮名・別名など）
    let story: Bool

    // スポット情報（ゆかりの地） - 複数対応
    var relatedSpots: [YokaiSpot]? = nil
    var mediaAppearances: [MediaAppearance]? = nil

    var videoId: String? = nil  // YouTube動画ID
}

struct NewsItem: Identifiable { let id = UUID(); let title: String; let link: URL?; let published: Date }
