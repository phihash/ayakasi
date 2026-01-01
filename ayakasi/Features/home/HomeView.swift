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
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
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
    
    var filteredEvents: [EventItem] {
        eventItems.filter { event in
            // isActiveがnilの場合は非表示（デフォルト値としてfalse扱い）
            guard event.isActive ?? false else { return false }
            
            // 期間チェック
            let now = Date()
            let formatter = ISO8601DateFormatter()
            
            // 開始時刻チェック
            if let startDateTimeString = event.startDateTime,
               let startDateTime = formatter.date(from: startDateTimeString),
               now < startDateTime {
                return false // まだ開始していない
            }
            
            // 終了時刻チェック
            if let endDateTimeString = event.endDateTime,
               let endDateTime = formatter.date(from: endDateTimeString),
               now > endDateTime {
                return false // すでに終了している
            }
            
            return true
        }
    }
    
    private func loadEvents() async {
        guard let url = URL(string: "https://raw.githubusercontent.com/phihash/JSON/refs/heads/main/event.json") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let events = try JSONDecoder().decode([EventItem].self, from: data)
            await MainActor.run {
                self.eventItems = events
            }
        } catch {
            print("❌ Failed to load events: \(error)")
        }
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                 
                
                HStack{
                    Text("イベント")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal,24)
                .padding(.vertical,12)
                
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
                                    onTap: {
                                        if let urlString = filteredEvents[index].link,
                                           let url = URL(string: urlString) {
                                            print("🔗 Event URL: \(urlString)")
                                            selectedEventUrl = url
                                        } else {
                                            print("❌ Invalid URL: \(filteredEvents[index].link ?? "nil")")
                                        }
                                    }
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 160)
                        .onReceive(timer) { _ in
                            if filteredEvents.count > 0 {
                                withAnimation(.easeInOut) {
                                    page = (page + 1) % filteredEvents.count
                                }
                            }
                        }
                    }
                }
                .padding(.bottom,16)
                
                
                HStack{
                    Text("ランキング")
                    
                    Spacer()
                }
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal,20)
                .padding(.vertical,8)
                
                ScrollView(.horizontal,showsIndicators: false){
                    
                    HStack(spacing: 16){
                        ForEach(rankedYokai.prefix(7)){ ayakasi in
                            PickupCard(ayakasi: ayakasi)
                                .onTapGesture{
                                    selectedYokai = ayakasi
                                }
                                .fullScreenCover(item: $selectedYokai){ yokai in
                                    NavigationStack {
                                        NeoDetail(yokai: yokai)
                                    }
                                }
                        }
                        
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom,24)
                }
                
                
                HStack{
                    Text("ニュース")
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
            
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadEvents()
            }
            .sheet(item: $selectedEventUrl) { url in
                WebView(url: url)
                    .onAppear {
                        print("🎬 Sheet showing with URL: \(url)")
                    }
            }
            
        }
    }
}
