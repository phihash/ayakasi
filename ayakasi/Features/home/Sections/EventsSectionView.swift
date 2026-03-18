import SwiftUI

struct EventsSection: View {
    let filteredEvents: [EventItem]
    @Binding var page: Int
    @Binding var selectedEventUrl: URL?

    var body: some View {
        Group {
            if filteredEvents.isEmpty {
                emptyState
            } else {
                eventsTabView
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

    private var eventsTabView: some View {
        VStack(spacing: 8) {
            TabView(selection: $page) {
                ForEach(filteredEvents.indices, id: \.self) { index in
                    EventComponent(
                        link: filteredEvents[index].link ?? "",
                        linkTitle: filteredEvents[index].title ?? "イベント",
                        imageUrl: filteredEvents[index].imageUrl,
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
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 250)

            pageIndicator
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(filteredEvents.indices, id: \.self) { index in
                Circle()
                    .fill(index == page ? Color.appTextSecondary : Color.appTextSecondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 2)
    }
}
