import Foundation
import MapKit

struct Highlight: Identifiable {
    let id = UUID()
    let name: String
    let accessInfo: String?
}

struct TownRevitalization: Identifiable {
    let id = UUID()
    let townName: String
    let coordinate: CLLocationCoordinate2D
    let description: String
    let prefecture: String
    let websiteURL: String?
    let imageURL: String?
    let highlights: [Highlight]?
}

enum SpotType {
    case yokaiRelated  // 特定の妖怪に関連するスポット
    case museum        // 美術館・博物館
    case culturalSite  // 文化施設・その他
}

struct YokaiSpot: Identifiable {
    let id = UUID()
    let spotName: String
    let coordinate: CLLocationCoordinate2D
    let description: String?
    let yokaiIds: [String]  // 空配列でもOK（美術館など）
    let prefecture: String
    let imageURL: String?
    let spotType: SpotType  // スポットのタイプ
}
