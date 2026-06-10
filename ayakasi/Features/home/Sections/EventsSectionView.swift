import SwiftUI

struct EventsSection: View {
    let filteredEvents: [EventItem]
    @Binding var selectedEventUrl: URL?

    var body: some View {
        if filteredEvents.isEmpty {
            emptyState
        } else {
            VStack(spacing: 8) {
                ForEach(filteredEvents.indices, id: \.self) { index in
                    EventComponent(
                        link: filteredEvents[index].link ?? "",
                        linkTitle: filteredEvents[index].title ?? "イベント",
                        location: filteredEvents[index].location,
                        startDateTime: filteredEvents[index].startDateTime,
                        endDateTime: filteredEvents[index].endDateTime,
                        onTap: {
                            if let urlString = filteredEvents[index].link,
                               let url = URL(string: urlString) {
                                selectedEventUrl = url
                            }
                        }
                    )
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
