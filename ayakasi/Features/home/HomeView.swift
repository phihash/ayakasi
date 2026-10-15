import SwiftUI
import os

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

enum HomeTab: String, CaseIterable {
    case events = "イベント"
    case news = "ニュース"
}

struct HomeView: View {
    @State private var tab: HomeTab = .events
    @State private var eventItems: [EventItem] = []
    @State private var selectedEventUrl: URL?
    @State private var noticeItem: NoticeItem?
    @EnvironmentObject private var router: DeepLinkRouter
    
    
    private static let isoFormatter = ISO8601DateFormatter()

    // お知らせの期間チェック(お知らせJSONは本当のUTC時刻で書かれている)
    private func isWithinDateRange(startDateTime: String?, endDateTime: String?) -> Bool {
        let now = Date()
        let formatter = Self.isoFormatter
        
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
    
    // 有効で、まだ終わっていないもの(開催前・開催中)
    var filteredEvents: [EventItem] {
        eventItems.filter { ($0.isActive ?? false) && !$0.hasEnded }
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
            Logger.data.error("イベント読み込み失敗: \(String(describing: error))")
            return []
        }
    }
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                tabBar

                // 中身は横スワイプでも切り替えられる(上のタブとselectionを共有)
                TabView(selection: $tab) {
                    ScrollView {
                        noticeView
                        EventsSection(
                            filteredEvents: filteredEvents,
                            selectedEventUrl: $selectedEventUrl
                        )
                        .padding(.top, 8)
                    }
                    .tag(HomeTab.events)

                    ScrollView {
                        noticeView
                        NewsView(selectedNew: "妖怪")
                            .padding(.top, 8)
                    }
                    .tag(HomeTab.news)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
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

    @ViewBuilder
    private var noticeView: some View {
        if let notice = activeNotice {
            NoticeSection(notice: notice)
        }
    }

    // 参考アプリの受信トレイと同じ、等幅ラベル+選択中だけ下線のタブ
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { item in
                let isSelected = item == tab
                Button {
                    withAnimation(.snappy) { tab = item }
                } label: {
                    Text(item.rawValue)
                        .font(.headline)
                        .foregroundStyle(isSelected ? Color.appSecondary : Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        .overlay(alignment: .bottom) {
                            Capsule()
                                .fill(isSelected ? Color.appSecondary : .clear)
                                .frame(width: 32, height: 4)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.horizontal, 24)
        .animation(.snappy(duration: 0.2), value: tab)
    }

    /// 通知タップで来たイベントURLを消化して SafariView で開く
    private func consumeEventDeepLink(_ url: URL?) {
        guard let url else { return }
        tab = .events
        selectedEventUrl = url
        router.pendingEventURL = nil
    }
}
