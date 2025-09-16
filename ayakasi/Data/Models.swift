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
    let info: String       // 図鑑的な情報
    let description: String       // 図鑑的な情報
    let traditional: String // 伝承・物語
    let tags : [String]
    let categories : [String]
    var aliases: [String]? = nil
    var features: String? = nil
    var distribution: String? = nil
    var episodes: [String]? = nil
    var cultures: String? = nil
    var references: [ReferenceLink]? = nil

}
