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

    private var startDateParts: (month: String, day: String)? {
        guard let start = event.startDateTime else { return nil }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        guard let startDate = inputFormatter.date(from: start) else { return nil }

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "M月"
        monthFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        dayFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        return (
            monthFormatter.string(from: startDate),
            dayFormatter.string(from: startDate)
        )
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

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                EventDateBadge(dateParts: startDateParts)

                VStack(alignment: .leading, spacing: 7) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        if let location = event.location, !location.isEmpty {
                            Text(location)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        if let location = event.location, !location.isEmpty, !formattedDateRange.isEmpty {
                            Text("・")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        if !formattedDateRange.isEmpty {
                            Text(formattedDateRange)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }

                Spacer(minLength: 8)

                if let status = eventStatus {
                    Text(status)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(status == "開催中" ? Color.appSuccess : Color.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((status == "開催中" ? Color.appSuccess : Color.appPrimary).opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct EventDateBadge: View {
    let dateParts: (month: String, day: String)?

    var body: some View {
        VStack(spacing: 1) {
            if let dateParts {
                Text(dateParts.month)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appSecondary)

                Text(dateParts.day)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            } else {
                Image(systemName: "calendar")
                    .font(.headline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(width: 46, height: 52)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
