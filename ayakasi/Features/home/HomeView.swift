import SwiftUI
import FeedKit
import Kingfisher

let publishedFormatter : DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ja_JP")
    f.dateStyle = .long
    f.timeStyle = .short
    return f
}()


struct PickupCard : View{
    let ayakasi: Ayakasi
    @EnvironmentObject var voteService: VoteService
    
    @ViewBuilder
    private var nameOverlay: some View {
        Text(ayakasi.name)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
            .padding(.leading,20)
            .padding(.bottom,20)
    }
    
    @ViewBuilder
    private var voteOverlay: some View {
        Capsule().fill(Color.red.opacity(0.9))
            .frame(width: 60, height: 30)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 1)
            .overlay(
                HStack{
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.white)
                    Text("\(voteService.voteCountCache[ayakasi.documentId] ?? 0)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            )
            .padding(.leading,8)
            .padding(.top,8)
    }
    
    @ViewBuilder
    private var storyOverlay: some View {
        if ayakasi.sotry{
            Circle().fill(Color.black.opacity(0.6))
                .frame(width: 40, height: 40)
                .overlay(
                    Image("book")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                )
                .padding(.trailing,8)
                .padding(.top,8)
        }
    }
    
    @ViewBuilder
    private func networkImage(url: URL) -> some View {
        KFImage(url)
            .placeholder {
                Image("loading")
                    .resizable()
                    .scaledToFill()
            }
            .cacheOriginalImage()
            .resizable()
            .scaledToFill()
            .frame(width: 180)
            .cornerRadius(12)
            .overlay(alignment: .bottomLeading) { nameOverlay }
            .overlay(alignment: .topLeading) { voteOverlay }
            .overlay(alignment: .topTrailing) { storyOverlay }
    }
    
    @ViewBuilder
    private var localImage: some View {
        Image(ayakasi.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 180)
            .cornerRadius(12)
            .overlay(alignment: .bottomLeading){
                Text(ayakasi.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.leading,20)
                    .padding(.bottom,20)
            }
    }
    
    var body: some View{
        ZStack{
            Group{
                if let url = URL(string: ayakasi.imageName), url.scheme?.hasPrefix("http") == true {
                    networkImage(url: url)
                } else {
                    localImage
                }
            }
        }
    }
}

struct NewsSection : View{
    @State private var items: [NewsItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject var colorVM : ColorViewModel
    var selectedNew : String
    let newsSources = [
        "妖怪":"https://www.google.co.jp/alerts/feeds/14350951871509070518/8255054665312320913",
        "イベント":"https://www.google.co.jp/alerts/feeds/14350951871509070518/14131475351883460019",
        "河童":"https://www.google.co.jp/alerts/feeds/14350951871509070518/13120840386550034680",
        "雪女":"https://www.google.co.jp/alerts/feeds/14350951871509070518/3735127170972070277",
    ]
    
    private func fetchFeed() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let urlString = newsSources[selectedNew] ?? (newsSources["妖怪"] ?? "")
            let atom = try await AtomFeed(urlString: urlString)
            let entries = atom.entries ?? []
            
            var seenTitles = Set<Substring>()
            
            self.items = entries.compactMap { e in
                let title = (e.title ?? "")
                let titlePrefix = title.prefix(8)
                if seenTitles.contains(titlePrefix) { return nil }
                seenTitles.insert(titlePrefix)
                let href =
                (e.links?.first { $0.attributes?.rel == "alternate" }?.attributes?.href)
                ?? e.links?.first?.attributes?.href
                
                let url = href.flatMap(URL.init(string:))
                
                let published = e.published ?? Date()
                return NewsItem(title: title.isEmpty ? "(無題)" : title, link: url, published: published)
            }
        } catch {
            self.errorMessage = "読み込みに失敗しました: \(error.localizedDescription)"
        }
    }
    
    var body : some View{
        ZStack{
            if isLoading {
                ProgressView("読み込み中…")
                    .frame(height: 320)
                
            } else if let msg =  errorMessage {
                Text(msg)
            }else{
                VStack(alignment: .leading) {
                    
                    ForEach(Array(items.indices), id: \.self) { index in
                        let item = items[index]
                        let title = item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                        if let url = item.link {
                            Link(destination: url) {
                                VStack(alignment: .leading, spacing: 12){
                                    Text(publishedFormatter.string(from: item.published))
                                        .foregroundStyle(.black.opacity(0.7))
                                        .font(.subheadline)
                                    Text("\(title)")
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .padding(.bottom,8)
                                    Rectangle()
                                        .fill(colorVM.currentColor)
                                        .frame(height: 1)
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .truncationMode(.tail)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                                .padding(.vertical,8)
                                .padding(.horizontal,20)
                                
                            }
                        } else {
                            Text("\(index + 1). \(title)")
                        }
                    }
                }
            }
        }
        .task(id: selectedNew) {
            await fetchFeed()
        }
        .refreshable{
            await  fetchFeed()
        }
    }
}

struct EventItem: Codable {
    let title: String
}

struct HomeView: View {
    @State private var page = 0
    @State private var selectedYokai : Ayakasi? = nil
    @State private var eventItems: [EventItem] = []
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
    
    private func loadEvents() async {
        guard let url = URL(string: "https://raw.githubusercontent.com/phihash/JSON/refs/heads/main/event.json") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let events = try JSONDecoder().decode([EventItem].self, from: data)
            print(events)
            await MainActor.run {
                self.eventItems = events
            }
        } catch {
            print("Failed to load events: \(error)")
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
                
                TabView(selection: $page) {
                    EventComponent(link: "https://miyoshi-mononoke.jp/", linkTitle: "妖気なもののけLIFE", iconName: "kappaicon",colorName: .customRed)
                        .tag(0)
                    
                    EventComponent(link: "https://sakai-yokai.com/", linkTitle: "沙界妖怪芸術祭", iconName: "warasiicon",colorName: .blue)
                        .tag(1)
                 
                    EventComponent(link: "https://www.yokaiexpo.com/", linkTitle: "YOKAI EXPO", iconName: "rokurokubiicon",colorName: .green)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 160)
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut) {
                        page = (page + 1) % 3
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
                                    NeoDetail(yokai: yokai)
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
                
                NewsSection(selectedNew: selectedNews)
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
        }
        
    }
}
