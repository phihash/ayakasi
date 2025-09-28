import SwiftUI

struct MenuSection : View{
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
                        
                        
                        ZStack{
                            EventComponent(link: "https://www.yokaibonodori.tokyo/", linkTitle: "妖怪盆踊り2025", iconName: "kozou")
                        }
                        .tag(1)
                        
                        
                        
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
                        }.tag(2)
                        
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
                        }.tag(3)
                        
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
                        }.tag(4)
                        
                        Link(destination: URL(string: "https://www.kanjimuseum.kyoto/kikakutenji/detail/kanji-yokai-chimi-moryo.html")!){
                            ZStack{
                                Rectangle()
                                    .fill(.yellow.opacity(0.6))
                                    .frame(width: screenWidth * 0.9)
                                    .cornerRadius(12)
                                
                                HStack{
                                    Spacer()
                                    Image("noppe")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth * 0.24) // サイズ調整
                                    
                                    
                                    Spacer()
                                    
                                    Text("妖怪漢字")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                    
                                    
                                    Spacer()
                                }
                                
                            }
                        }.tag(5)
                        
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic)) // ドット表示
                    .frame(height: 130)
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut) {
                            page = (page + 1) % 6  // 最後→最初にループ 4枚なので
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
                            name: "件",
                            imageName: "kudan",
                            description: "件（くだん）は、牛の体に人の顔を持ち、牛からうまれる。\n地域によって、下は牛以外にも馬・ヘビ・魚などの生き物であると伝えられる。\n件（くだん）は、牛からうまれたあとに、その年の吉報あるいは災いを予言し、数日ほどで死ぬと伝えられ、その予言は決して外れないと言われた。",
                            tags: ["すべて"],
                            categories: ["山の怪"],
                            btw: "作家小松左京の、くだんのははという短編小説で題材にされている。",
                            episodes: "具体的な逸話として、昔、牛からうまれた後に、「これから大変な世の中になるから、ヒエやアワなどの食料を蓄えるように」と告げ数日で死んだ。まもなくして、戦争が始まり、予言を告げられたものは食べ物に困らなかったという。\n ",
                        ),
                        Ayakasi(
                            name: "小豆洗い",
                            imageName: "azukiarai",
                            description: "小豆洗い（あずきあらい）は川で小豆を洗う妖怪で、小豆とぎ（あずきとぎ）、小豆あらいど（あずきあらいど）など、様々な呼び名で全国的に分布している。\n小豆洗いは、川のほとりでシャキシャキと小豆をとぐ音が聞こえ、音をする方にいってもその姿はないといったものや、「小豆洗おか、人取って喰おか」など歌いながら小豆を洗うタイプもいる。",
                            tags: ["すべて"],
                            categories: ["音の怪","水の怪"],
                            btw: "小豆は収獲後乾燥して保存した際のごみや虫を除くために洗います。",
                            episodes: "「ショキショキ」「ザクザク」と豆を研ぐ音が続き、覗くと波紋だけが残っていたという怪談がある。",
                        ),
                        Ayakasi(
                            name: "河童",
                            imageName: "kappa",
                            description:"カッパは、日本全国の川・池・沼・海などの水界に棲み、陸上も歩行する。カッパという呼称が一般的であるが、ガワタロ、メドチなど場所によっていろいろな呼び方がある。",
                            tags: ["人型","脅かす","怖い","すべて"],
                            categories: ["水の怪"],
                            btw: nil,
                            episodes: "カッパは、子供を溺死させたり、馬を川へ引きずり込んだり、田畑を荒らしたりするといった恐ろしい一面をもつ一方で、田植え、田の草取りの手伝いをしたり、命を助けてもらったお礼として人間に薬の製法を教えたりもするといったエピソードもある",
                            
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
                    
                }
                
                
                
                VStack(spacing: 20){
                    VStack(alignment: .leading,spacing: 20){
                        HStack{
                            VStack(alignment: .leading, spacing: 12){
                                Text("妖怪とは？")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("日本各地の伝承に登場する、不思議な存在の総称。人々の恐怖や自然への畏れから生まれ、時に教訓や娯楽として語られてきた。")
                                    .font(.subheadline)
                            }
                            Image("yokai")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.25)
                            
                        }
                    }
                    .frame(width: screenWidth * 0.86,height : 160)
                    .padding(12)
                    .background(Color(.white))
                    .cornerRadius(12)
                    
                    
                }
                .padding(.horizontal,16)
                .padding(.vertical,24)
                
                
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
