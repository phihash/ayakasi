import SwiftUI

struct EventListItem: View {
    let event: EventItem
    let action: () -> Void

    private var title: String {
        event.title ?? "イベント"
    }

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return f
    }()

    private var formattedDateRange: String {
        guard let start = event.startDate, let end = event.endDate else { return "" }
        return "\(Self.displayFormatter.string(from: start)) - \(Self.displayFormatter.string(from: end))"
    }

    // 終わったイベントは一覧(HomeView.filteredEvents)に来ないので、開催前か開催中のどちらか
    private var eventStatus: String {
        event.hasStarted ? "開催中" : "開催前"
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

                        Text(eventStatus)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(event.hasStarted ? Color.appSecondary : Color.appTextSecondary)
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
