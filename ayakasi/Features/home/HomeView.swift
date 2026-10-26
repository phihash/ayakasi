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

enum HomeTab: String, UnderlineTab {
    case events = "イベント"
    case news = "ニュース"
    var icon: String? { nil }
}

// 画面上部の切り替えタブ(イベント・ニュース)
protocol UnderlineTab: Hashable, CaseIterable where AllCases: RandomAccessCollection {
    var rawValue: String { get }
    var icon: String? { get }  // Assets.xcassets の画像名
}

// ホームのイベント・ニュース切り替え。カードの一覧の上に置くので、下線よりカプセルの方がなじむ
struct PillTabBar<Tab: UnderlineTab>: View {
    @Binding var selection: Tab
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(Tab.allCases), id: \.self) { item in
                let isSelected = item == selection
                Button {
                    withAnimation(.snappy(duration: 0.25)) { selection = item }
                } label: {
                    Text(item.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(isSelected ? Color.white : Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.appSecondary)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.appCardBackground))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
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
    
    // 有効で、まだ終わっていないもの。開催中(画像あり)→開催中(画像なし)→開催前の順
    // sortでなく段ごとにfilterするのは、Swiftのsortが安定でなく、段の中の開催日順(Workerの並び)が崩れるため
    var filteredEvents: [EventItem] {
        let shown = eventItems.filter { ($0.isActive ?? false) && !$0.hasEnded }
        let rank = { (e: EventItem) in !e.hasStarted ? 2 : (e.image == nil ? 1 : 0) }
        return (0...2).flatMap { r in shown.filter { rank($0) == r } }
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
                PillTabBar(selection: $tab)

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

    /// 通知タップで来たイベントURLを消化して SafariView で開く
    private func consumeEventDeepLink(_ url: URL?) {
        guard let url else { return }
        tab = .events
        selectedEventUrl = url
        router.pendingEventURL = nil
    }
}
