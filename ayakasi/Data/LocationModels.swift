import Foundation
import MapKit

struct YokaiDestination: Identifiable, Decodable {
    let id = UUID()
    let name: String  // 町名・施設名
    let coordinate: CLLocationCoordinate2D
    let description: String
    let prefecture: String
    let kind: String?  // D1のkind。"facility"=施設 / "related"=ゆかりの地 / 無し=町(kind導入前の行を町として読むため)

    private enum CodingKeys: String, CodingKey {
        case name, latitude, longitude, description, prefecture, kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        coordinate = CLLocationCoordinate2D(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude)
        )
        description = try container.decode(String.self, forKey: .description)
        prefecture = try container.decode(String.self, forKey: .prefecture)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
    }
}

enum SpotType: String, Decodable {
    case yokaiRelated  // 特定の妖怪に関連するスポット
    case museum        // 美術館・博物館
    case culturalSite  // 文化施設・その他
}

struct YokaiSpot: Identifiable, Decodable {
    let id = UUID()
    let spotName: String
    let coordinate: CLLocationCoordinate2D
    let description: String?
    let yokaiIds: [String]  // 空配列でもOK（美術館など）
    let prefecture: String
    let spotType: SpotType  // スポットのタイプ

    private enum CodingKeys: String, CodingKey {
        case spotName, latitude, longitude, description, yokaiIds, prefecture, spotType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        spotName = try container.decode(String.self, forKey: .spotName)
        coordinate = CLLocationCoordinate2D(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude)
        )
        description = try container.decodeIfPresent(String.self, forKey: .description)
        yokaiIds = try container.decode([String].self, forKey: .yokaiIds)
        prefecture = try container.decode(String.self, forKey: .prefecture)
        spotType = try container.decode(SpotType.self, forKey: .spotType)
    }
}
