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
    
    private let feedURLString = "https://www.google.co.jp/alerts/feeds/14350951871509070518/8255054665312320913"
    
    private func fetchFeed() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let atom = try await AtomFeed(urlString: feedURLString)
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
        .task{
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
                    let koteis = [
                        Ayakasi(
                            name: "牛鬼",
                            imageName: "usioni",
                            description: "頭が牛で首から下は蜘蛛のような胴体、あるいはその逆の場合もある。人を襲うとされ、牛鬼が出現する前に、濡れ女が赤ん坊を抱かせようとしてくる。\n島根県で牛鬼の伝承が多い。",
                            tags: ["怖い","すべて"],
                            categories: ["水の怪"],
                            btw: nil,
                            episodes: "男が釣りから帰ろうとしたとき、濡女が現れて赤子を渡すと消えてしまった。\n赤子を離そうとしても、石のようになって手から離れず、その間に牛鬼があらわれ襲いかかろうとするが、なんとか逃げ切って助かったという伝承がある。\n",
                        ),
                        Ayakasi(
                            name: "うわん",
                            imageName: "uwan",
                            description: "画図百鬼夜行や百怪図巻などに描かれた妖怪。お歯黒で、3本指の先には鋭い爪がついている。名前の通り、うわんと大きな声で人を驚かす。",
                            tags: ["人型","すべて"],
                            categories: ["音の怪"],
                            btw: nil,
                            episodes: "江戸時代、青森県の夫婦が古い屋敷に引っ越したその夜、「うわん」という大声が響いて一睡できなかった。\n近所の老人から「古い屋敷にはうわんという怪物が住んでいる」と聞いた。",
                        ),
                        Ayakasi(
                            name: "かまいたち",
                            imageName: "kamaitati",
                            description: "かまいたちは、外見はイタチに似ると考えられる一方、実際には人間の目には見えないともされる。また、痛みを感じないうちに深い傷を負わせるが、そのわりには出血はしない現象を指す。",
                            tags: ["動物","すべて"],
                            categories: ["動物の怪"],
                            btw: nil,
                            episodes: "岐阜県の飛騨地方などでは、かまいたちは「カマイタチ」という三人の神様と捉えられる。\n最初の神様がぶつかって人を転ばせ、二番目の神様が切りつけ、三番目の神様が薬をつけて治す。よって、鎌で切ったような傷の形をしていながら、出血や痛みがないとされる。",
                        )
                        
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
                .padding(.vertical,16)
                
                
                
                NewsSection()
                
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
