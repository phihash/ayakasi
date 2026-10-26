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

    // ニュースタブの NewsListItem と同じカード(ListCard)にそろえる(同じ画面のタブで見た目が違うと浮くため)
    var body: some View {
        Button(action: action) {
            // 開催前は画像があっても出さない(大きな画像は今行けるイベントの目印にするため)
            ListCard(image: event.hasStarted ? event.image.flatMap(URL.init(string:)) : nil, systemImage: "calendar",
                     title: title, phrases: event.phrases) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(subtitle)
                        .foregroundStyle(Color.appTextSecondary)

                    Spacer(minLength: 0)

                    Text(eventStatus)
                        .foregroundStyle(event.hasStarted ? Color.appSecondary : Color.appTextSecondary)
                }
                .font(.caption)
                .fontWeight(.semibold)
            }
        }
        .buttonStyle(.plain)
    }
}
