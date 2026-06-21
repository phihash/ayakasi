import SwiftUI

struct EventItem: Codable {
    let title: String?
    let link: String?
    let startDateTime: String?
    let endDateTime: String?
    let location: String?
    let isActive: Bool?
}

struct NoticeItem: Codable {
    let message: String
    let isActive: Bool
    let startDateTime: String?
    let endDateTime: String?
}
