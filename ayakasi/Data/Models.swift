import Foundation
import MapKit

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
    let description: String
    let categories : [String]
    let relatedCategory: String?    // 関連カテゴリ（"すべて"以外の具体的なカテゴリ）
    var references: [ReferenceLink]? = nil
    var searchKeywords: [String]? = nil  // 検索用キーワード（読み仮名・別名など）
    let story: Bool

    // スポット情報（ゆかりの地） - 複数対応
    var relatedSpots: [YokaiSpot]? = nil

    var videoId: String? = nil  // YouTube動画ID
}

struct NewsItem: Identifiable { let id = UUID(); let title: String; let link: URL?; let published: Date }
