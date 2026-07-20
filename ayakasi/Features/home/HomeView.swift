import SwiftUI
import FeedKit
import Kingfisher
import FirebaseFirestore

extension URL: Identifiable {
    public var id: String { absoluteString }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        return formatter
    }()
}

struct HomeView: View {
    @State private var selectedYokai : Ayakasi? = nil
    @State private var eventItems: [EventItem] = []
    @State private var selectedEventUrl: URL?
    @State private var noticeItem: NoticeItem?
    @EnvironmentObject private var router: DeepLinkRouter
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    let screenWidth = UIScreen.main.bounds.width
    
    // 期間チェック共通関数
    private func isWithinDateRange(startDateTime: String?, endDateTime: String?) -> Bool {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        
        // 開始時刻チェック
        if let startDateTimeString = startDateTime,
           let startDateTime = formatter.date(from: startDateTimeString),
           now < startDateTime {
            return false // まだ開始していない
        }
        
        // 終了時刻チェック
        if let endDateTimeString = endDateTime,
           let endDateTime = formatter.date(from: endDateTimeString),
           now > endDateTime {
            return false // すでに終了している
        }
        
        return true
    }
    
    var filteredEvents: [EventItem] {
        eventItems.filter { event in
            guard event.isActive ?? false else { return false }

            // 終了チェックのみ（終了していなければ表示）
            let now = Date()
            let formatter = ISO8601DateFormatter()

            if let endDateTimeString = event.endDateTime,
               let endDateTime = formatter.date(from: endDateTimeString),
               now > endDateTime {
                return false // すでに終了している
            }

            return true // 開催予定または開催中
        }
    }
    
    var activeNotice: NoticeItem? {
        guard let notice = noticeItem else { return nil }
        guard notice.isActive else { return nil }
        return isWithinDateRange(startDateTime: notice.startDateTime, endDateTime: notice.endDateTime) ? notice : nil
    }
    
    private func loadNoticeItem() async -> NoticeItem? {
        guard let url = URL(string: AppConstants.noticeDataURL) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let notice = try JSONDecoder().decode(NoticeItem.self, from: data)
            return notice
        } catch{
            return nil
        }
    }
    
    private func loadEvents() async {
        async let eventsResult = loadEventsData()
        async let noticeResult = loadNoticeItem()
        
        let (events, notice) = await (eventsResult, noticeResult)
        
        await MainActor.run {
            self.eventItems = events
            self.noticeItem = notice
        }
    }
    
    private func loadEventsData() async -> [EventItem] {
        guard let url = URL(string: AppConstants.events2DataURL) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let events = try JSONDecoder().decode([EventItem].self, from: data)
            return events
        } catch {
            print("❌ Failed to load events: \(error)")
            return []
        }
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                if let notice = activeNotice {
                    NoticeSection(notice: notice)
                }

                HStack{
                    Text("全国の妖怪イベント!")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal,24)

                EventsSection(
                    filteredEvents: filteredEvents,
                    selectedEventUrl: $selectedEventUrl
                )

                NewsSection()
            }
            .background(Color.appBackground)
            
            .navigationTitle("イベント・ニュース")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadEvents()
            }
            .sheet(item: $selectedEventUrl) { url in
                SafariView(url: url)
            }
            .onChange(of: router.pendingEventURL) { _, url in
                consumeEventDeepLink(url)
            }
            .onAppear {
                // イベントタブを見たタイミングで通知許可を求める（未決定のときだけ）
                PushAuthorization.requestIfNeeded()
                // コールド起動（通知タップで起動）時の取りこぼし対策
                consumeEventDeepLink(router.pendingEventURL)
            }
        }
    }

    /// 通知タップで来たイベントURLを消化して SafariView で開く
    private func consumeEventDeepLink(_ url: URL?) {
        guard let url else { return }
        selectedEventUrl = url
        router.pendingEventURL = nil
    }
}
