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

struct YokaiSpot: Identifiable {
    let id = UUID()
    let spotName: String
    let coordinate: CLLocationCoordinate2D
    let description: String?
    let yokaiIds: [String]
    let prefecture: String
    let imageURL: String?
}
