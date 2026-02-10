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
    @State private var page = 0
    @State private var selectedYokai : Ayakasi? = nil
    @State private var eventItems: [EventItem] = []
    @State private var selectedEventUrl: URL?
    @State private var noticeItem: NoticeItem?
    @EnvironmentObject var colorVM : ColorViewModel
    @EnvironmentObject var voteService  : VoteService
    
    @State var selectedNews = "妖怪"
    let newsYokai = ["妖怪","イベント","雪女","河童"]
    var rankedYokai : [Ayakasi] {
        ayakasis.sorted{ element1 , element2 in
            let count1 = voteService.voteCountCache[element1.documentId] ?? 0
            let count2 = voteService.voteCountCache[element2.documentId] ?? 0
            return count1 > count2
        }
    }
    
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
            return isWithinDateRange(startDateTime: event.startDateTime, endDateTime: event.endDateTime)
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
                    VStack {
                        HStack {
                            Image(systemName: "megaphone")
                                .foregroundColor(.orange)
                            Text(notice.message)
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                
                HStack{
                    Text("全国で開催中の妖怪イベント!")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal,24)
                .padding(.vertical,6)
                
                Group {
                    if filteredEvents.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("イベントを取得中です")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 160)
                    } else {
                        TabView(selection: $page) {
                            ForEach(filteredEvents.indices, id: \.self) { index in
                                EventComponent(
                                    link: filteredEvents[index].link ?? "",
                                    linkTitle: filteredEvents[index].title ?? "イベント",
                                    imageUrl: filteredEvents[index].imageUrl,
                                    location: filteredEvents[index].location,
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
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(height: 280)
                        .padding(.vertical, 12)
                    }
                }
                
            
                HStack{
                    Text("妖怪関連ニュース")
                    Spacer()
                }
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal,20)
                .padding(.top,4)
                
                HStack{
                    ForEach(newsYokai,id:\.self){ element in
                        Button{
                            selectedNews = element
                        } label :{
                            Text(element)
                                .font(.subheadline)
                                .foregroundStyle(selectedNews == element ? .white : colorVM.currentColor)
                                .fontWeight(.bold)
                                .padding(.vertical,6)
                                .padding(.horizontal,18)
                                .background(selectedNews == element ? colorVM.currentColor : .clear)
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(colorVM.currentColor, lineWidth: 2)
                                )
                                .onTapGesture { selectedNews = element }
                        }
                    }
                    Spacer()
                }
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal,20)
                .padding(.vertical,16)
                
                NewsView(selectedNew: selectedNews)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                let currentNewsIndex = newsYokai.firstIndex(of: selectedNews) ?? 0
                                
                                if value.translation.width > 50 {
                                    let newIndex = max(0,currentNewsIndex - 1)
                                    withAnimation{
                                        selectedNews = newsYokai[newIndex]
                                    }
                                } else if value.translation.width < -50 {
                                    let newIndex = min(newsYokai.count - 1, currentNewsIndex + 1)
                                    withAnimation{
                                        selectedNews = newsYokai[newIndex]
                                    }
                                }
                            }
                    )
            }
            .background(Color("Ivory"))
            
            .navigationTitle("イベント・ニュース")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadEvents()
            }
            .sheet(item: $selectedEventUrl) { url in
                SafariView(url: url)
                    .onAppear {
                        print("🎬 Sheet showing with URL: \(url)")
                    }
            }
        }
    }
}
