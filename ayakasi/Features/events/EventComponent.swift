import SwiftUI
import Kingfisher

struct EventItem: Codable {
    let title: String?
    let link: String?
    let imageUrl: String?
    let startDateTime: String?
    let endDateTime: String?
    let location: String?
    let isActive: Bool?
    let minVersion: String?
    let maxVersion: String?
    let bannerType: String?
}

struct NoticeItem: Codable {
    let message: String
    let isActive: Bool
    let startDateTime: String?
    let endDateTime: String?
}

struct EventComponent: View {
    @State private var ogImage: Image?
    let screenWidth = UIScreen.main.bounds.width
    let link : String
    let linkTitle : String
    let imageUrl : String?
    let location : String?
    let startDateTime : String?
    let endDateTime : String?
    let onTap: () -> Void

    private var formattedDateRange: String {
        guard let start = startDateTime, let end = endDateTime else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "M/d"
        displayFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        if let startDate = inputFormatter.date(from: start),
           let endDate = inputFormatter.date(from: end) {
            return "\(displayFormatter.string(from: startDate)) - \(displayFormatter.string(from: endDate))"
        }
        return ""
    }

    private var eventStatus: String? {
        let now = Date()

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!

        // 開始前チェック
        if let start = startDateTime,
           let startDate = inputFormatter.date(from: start),
           now < startDate {
            return "開催前"
        }

        // 終了チェック（終了日の翌日00:00:00以降を終了とする）
        if let end = endDateTime,
           let endDate = inputFormatter.date(from: end),
           let nextDay = calendar.date(byAdding: .day, value: 1, to: endDate),
           now >= nextDay {
            return nil // 終了（表示しない）
        }

        return "開催中"
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 8) {
                if let status = eventStatus {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.caption2)
                            .foregroundStyle(status == "開催中" ? Color.appSuccess : Color.appPrimary)

                        Text(status)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(status == "開催中" ? Color.appSuccess : Color.appPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                KFImage(imageUrl.flatMap { URL(string: $0) })
                    .placeholder {
                        Image("loading_banner")
                            .resizable()
                            .scaledToFill()
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(linkTitle)
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                            .fontWeight(.bold)

                        HStack(spacing: 8) {
                            Text(location ?? "")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appTextPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.appTextSecondary.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            if !formattedDateRange.isEmpty {
                                Text(formattedDateRange)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 12)
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
            .frame(width: screenWidth * 0.72)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 1, y: 0.5)
        }
    }
}
