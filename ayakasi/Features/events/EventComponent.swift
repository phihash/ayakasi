import SwiftUI

struct EventItem: Codable {
    let title: String?
    let link: String?
    let startDateTime: String?
    let endDateTime: String?
    let location: String?
    let isActive: Bool?
    let image: String?
    let phrases: [String]?
}

extension EventItem {
    // 管理画面は日付だけを "2026-10-20T00:00:00Z" の形で保存する。末尾はZだが中身は日本の日付なので、東京時間として読む
    private static let parser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return f
    }()

    var startDate: Date? { startDateTime.flatMap(Self.parser.date(from:)) }
    var endDate: Date? { endDateTime.flatMap(Self.parser.date(from:)) }
    var hasStarted: Bool { startDate.map { Date() >= $0 } ?? true }
    var hasEnded: Bool { endDate.map { Date() > $0 } ?? false }
}

struct NoticeItem: Codable {
    let message: String
    let isActive: Bool
    let startDateTime: String?
    let endDateTime: String?
}
