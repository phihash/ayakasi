import SwiftUI
import FeedKit

let publishedFormatter : DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ja_JP")
    f.dateStyle = .long
    f.timeStyle = .short
    return f
}()

struct MenuSection: View{
    let text : String
    let imageName: String
    let screenWidth = UIScreen.main.bounds.width
    var body: some View{
        HStack{
            Image(imageName)
                .resizable()
                .frame(width: screenWidth * 0.12, height: screenWidth * 0.12)
            Text(text)
                .font(.headline)
                .foregroundStyle(.black)
                .fontWeight(.bold)
                .padding(.trailing,18)
        }
        .padding(.vertical,12)
        .frame(width: screenWidth * 0.45)
        .background(Color.white)
        .cornerRadius(12)
    }
}


struct PickupCard : View{
    let ayakasi: Ayakasi
    var body: some View{
        ZStack{
            Image(ayakasi.imageName)
                .resizable()
                .scaledToFit()
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
            self.items = entries.compactMap { e in
                let title = (e.title ?? "")
                
                // rel="alternate" を優先、なければ先頭リンク
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
            } else if let msg =  errorMessage {
                Text(msg)
            }else{
                VStack(alignment: .leading) {
                    
                    ForEach(Array(items.indices), id: \.self) { index in
                        let item = items[index]
                        let title = item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                        if let url = item.link {
                            Link(destination: url) {
                                VStack(alignment: .leading, spacing: 8){
                                    Text("\(index + 1). \(title)")
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                    Text(publishedFormatter.string(from: item.published))
                                        .font(.caption)
                                        .foregroundStyle(.black.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .truncationMode(.tail)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                                .padding(16)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal,12)
                                
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

struct HomeView: View {
    @State private var page = 0
    @State private var selectedYokai : Ayakasi? = nil
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    @EnvironmentObject var colorVM : ColorViewModel
    @State var selectedNews = "妖怪"
    let newsYokai = ["妖怪","イベント","雪女","河童"]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    let screenWidth = UIScreen.main.bounds.width
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
                .padding(.vertical,16)
                
                
                VStack(spacing: 16){
                    TabView(selection: $page) {
                        
                        ZStack{
                            EventComponent(link: "https://www.toei-eigamura.com/yokai/", linkTitle: "怪々Yokai祭2025", iconName: "kappaicon")
                            
                        }
                        .tag(0)
                        
                        
                        Link(destination: URL(string: "https://sakai-yokai.com/")!){
                            ZStack{
                                Rectangle()
                                    .fill(.blue.opacity(0.6))
                                    .frame(width: screenWidth * 0.9)
                                    .cornerRadius(12)
                                
                                HStack{
                                    Spacer()
                                    Image("warasiicon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth * 0.24) // サイズ調整
                                    
                                    Spacer()
                                    Text("沙界妖怪芸術祭")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                
                            }
                        }.tag(1)
                        
                        Link(destination: URL(string: "https://www.yokaiexpo.com/")!){
                            ZStack{
                                Rectangle()
                                    .fill(.purple.opacity(0.6))
                                    .frame(width: screenWidth * 0.9)
                                    .cornerRadius(12)
                                
                                HStack{
                                    Spacer()
                                    Image("rokurokubiicon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth * 0.24) // サイズ調整
                                    
                                    Spacer()
                                    Text("YOKAI EXPO")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                
                            }
                        }.tag(2)
                        
                        Link(destination: URL(string: "https://www.jidaimura.com/edomura-yokai-wonderland")!){
                            ZStack{
                                Rectangle()
                                    .fill(.pink.opacity(0.6))
                                    .frame(width: screenWidth * 0.9)
                                    .cornerRadius(12)
                                
                                HStack{
                                    Spacer()
                                    
                                    Text("妖怪ワンダーランド")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    Image("yukiicon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth * 0.24) // サイズ調整
                                    
                                    Spacer()
                                }
                                
                            }
                        }.tag(3)
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic)) // ドット表示
                    .frame(height: 130)
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut) {
                            page = (page + 1) % 4  // 最後→最初にループ 4枚なので
                        }
                    }
                }
                .padding(.bottom,16)
                
                
                HStack{
                    Text("アップデート")
                    Spacer()
                }
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal,20)
                .padding(.vertical,16)
                
                ScrollView(.horizontal,showsIndicators: false){
                    let koteis : [Ayakasi] = [
                        Ayakasi(
                            name: "のっぺらぼう",
                            imageName: "kaonasi",
                            description: "ふつうの人型であるが、顔には目,鼻,耳,口がない妖怪",
                            tags: ["人型","夜道","脅かす","すべて"],
                            categories: ["道の怪"],
                            btw: "現時点で、のっぺらぼうという言葉が記録された最初の文献は、松尾芭蕉の詠んだ句である",
                            episodes: "おいてけ堀で釣った魚を持って帰ろうとすると、のっぺらぼうが現れ、逃げた先でも遭遇する。\nおいてけ堀の「おいてけ〜」という声の主は、河童とも言われており、おいてけ掘の舞台は、現在の錦糸町周辺とされる。",
                        ),
                        Ayakasi(
                            name: "牛鬼",
                            imageName: "usioni",
                            description: "頭が牛で首から下は蜘蛛のような胴体、あるいはその逆の場合もある。人を襲うとされ、牛鬼が出現する前に、濡れ女が赤ん坊を抱かせようとしてくる。\n島根県で牛鬼の伝承が多い。",
                            tags: ["怖い","すべて"],
                            categories: ["水の怪"],
                            btw: nil,
                            episodes: "男が釣りから帰ろうとしたとき、濡女が現れて赤子を渡すと消えてしまった。\n赤子を離そうとしても、石のようになって手から離れず、その間に牛鬼があらわれ襲いかかろうとするが、なんとか逃げ切って助かったという伝承がある。\n",
                        ),
                        
                    ]
                    HStack(spacing: 16){
                        ForEach(koteis){ ayakasi in
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
                    .padding(.bottom,16)
                }
                
                HStack{
                    Text("ニュース")
                    Spacer()
                }
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal,20)
                .padding(.top,16)
                
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
                
                
                // 3.ピックアップ
                HStack{
                    Text("ピックアップ")
                    
                    Spacer()
                    
                    NavigationLink{
                        let filtered = ayakasis.filter({$0.tags.contains("すべて")})
                        FilteredScreen(ayakasis:filtered,tag:"すべて")
                    } label: {
                        Text("全てを見る")
                        Image(systemName: "chevron.right")
                    }
                    
                }
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal,20)
                .padding(.vertical,16)
                
                ScrollView(.horizontal,showsIndicators: false){
                    
                    HStack(spacing: 16){
                        ForEach(ayakasis.shuffled().prefix(5)){ ayakasi in
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
            }
            
            .background(Color("Ivory"))
            .toolbar{
                ToolbarItem(placement:.navigationBarTrailing){
                    NavigationLink(destination: SettingView() ){
                        Image("setting")
                    }
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}
