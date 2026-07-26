import Foundation
import MapKit

struct Highlight: Identifiable {
    let id = UUID()
    let name: String
    let accessInfo: String?
}

struct YokaiDestination: Identifiable {
    let id = UUID()
    let name: String  // 町名・施設名
    let coordinate: CLLocationCoordinate2D
    let description: String
    let prefecture: String
    let websiteURL: String?
    let imageURL: String?
    let highlights: [Highlight]?
}

enum SpotType: String, Codable {
    case yokaiRelated  // 特定の妖怪に関連するスポット
    case museum        // 美術館・博物館
    case culturalSite  // 文化施設・その他
}

struct YokaiSpot: Identifiable, Codable {
    let id = UUID()
    let spotName: String
    let coordinate: CLLocationCoordinate2D
    let description: String?
    let yokaiIds: [String]  // 空配列でもOK（美術館など）
    let prefecture: String
    let imageURL: String?
    let spotType: SpotType  // スポットのタイプ

    private enum CodingKeys: String, CodingKey {
        case spotName, latitude, longitude, description, yokaiIds, prefecture, imageURL, spotType
    }

    init(spotName: String, coordinate: CLLocationCoordinate2D, description: String?, yokaiIds: [String], prefecture: String, imageURL: String?, spotType: SpotType) {
        self.spotName = spotName
        self.coordinate = coordinate
        self.description = description
        self.yokaiIds = yokaiIds
        self.prefecture = prefecture
        self.imageURL = imageURL
        self.spotType = spotType
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
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        spotType = try container.decode(SpotType.self, forKey: .spotType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spotName, forKey: .spotName)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(yokaiIds, forKey: .yokaiIds)
        try container.encode(prefecture, forKey: .prefecture)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(spotType, forKey: .spotType)
    }
}
