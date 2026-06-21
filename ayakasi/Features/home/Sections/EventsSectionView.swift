import SwiftUI

struct EventsSection: View {
    let filteredEvents: [EventItem]
    @Binding var selectedEventUrl: URL?

    var body: some View {
        if filteredEvents.isEmpty {
            emptyState
        } else {
            VStack(spacing: 2) {
                ForEach(filteredEvents.indices, id: \.self) { index in
                    EventListItem(event: filteredEvents[index]) {
                        if let urlString = filteredEvents[index].link,
                           let url = URL(string: urlString) {
                            Analytics.trackEventLinkTapped(
                                title: filteredEvents[index].title ?? "イベント",
                                link: urlString
                            )
                            selectedEventUrl = url
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.appTextSecondary)

            Text("イベントを取得中です")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.appTextSecondary)
        }
        .frame(height: 160)
    }
}
