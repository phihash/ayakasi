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

struct EventComponent: View {
    let link: String
    let linkTitle: String
    let location: String?
    let startDateTime: String?
    let endDateTime: String?
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

        if let start = startDateTime,
           let startDate = inputFormatter.date(from: start),
           now < startDate {
            return "開催前"
        }

        if let end = endDateTime,
           let endDate = inputFormatter.date(from: end),
           let nextDay = calendar.date(byAdding: .day, value: 1, to: endDate),
           now >= nextDay {
            return nil
        }

        return "開催中"
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(linkTitle)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        if let location, !location.isEmpty {
                            Text(location)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appTextPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.appTextSecondary.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }

                        if !formattedDateRange.isEmpty {
                            Text(formattedDateRange)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }

                Spacer()

                if let status = eventStatus {
                    Text(status)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(status == "開催中" ? Color.appSuccess : Color.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((status == "開催中" ? Color.appSuccess : Color.appPrimary).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
    }
}
