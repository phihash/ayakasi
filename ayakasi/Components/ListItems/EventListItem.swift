import SwiftUI

struct EventListItem: View {
    let event: EventItem
    let action: () -> Void

    private var title: String {
        event.title ?? "イベント"
    }

    private var formattedDateRange: String {
        guard let start = event.startDateTime, let end = event.endDateTime else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "M/d"
        displayFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        guard let startDate = inputFormatter.date(from: start),
              let endDate = inputFormatter.date(from: end) else {
            return ""
        }

        return "\(displayFormatter.string(from: startDate)) - \(displayFormatter.string(from: endDate))"
    }

    private var eventStatus: String? {
        let now = Date()

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!

        if let start = event.startDateTime,
           let startDate = inputFormatter.date(from: start),
           now < startDate {
            return "開催前"
        }

        if let end = event.endDateTime,
           let endDate = inputFormatter.date(from: end),
           let nextDay = calendar.date(byAdding: .day, value: 1, to: endDate),
           now >= nextDay {
            return nil
        }

        return "開催中"
    }

    // 場所・期間を1行にまとめた2行目(どちらも無ければ出さない)
    private var subtitle: String {
        [event.location ?? "", formattedDateRange].filter { !$0.isEmpty }.joined(separator: "・")
    }

    // ニュースタブの NewsListItem と同じ寸法・配色にそろえる(同じ画面のタブで行の見た目が違うと浮くため)
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: 24, height: 24)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 0)

                        if let status = eventStatus {
                            Text(status)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(status == "開催中" ? Color.appSecondary : Color.appTextSecondary)
                        }
                    }

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
