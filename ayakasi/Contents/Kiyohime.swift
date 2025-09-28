import SwiftUI

struct Kiyohime: View {
    let screenWidth = UIScreen.main.bounds.width
    @EnvironmentObject var colorVM : ColorViewModel
    @Environment(\.dismiss) private var dismiss
    private let sections: [(title: String, body: String)] = [
        ("若き僧の旅",
         "平安時代、紀州熊野を目指す若い僧・安珍が旅をしていました。真面目で美しい容姿の彼は、多くの人々に注目される存在でした。"),
        ("清姫との出会い",
         "旅の途中、安珍は日高川近くに住む清姫の家に宿を求めます。清姫は地主の娘で、美しいながらも情熱的な心を持っていました。"),
        ("一目惚れ",
         "清姫は安珍の姿に一目で心を奪われます。夜更けまで言葉を交わすうちに、彼への恋心はますます募っていきました。"),
        ("禁欲と拒絶",
         "しかし安珍は修行の身。「女人に心を許すことはできない」と、清姫の想いを断ち切ろうとします。ただ冷たく突き放すことはできず、「帰りにまた立ち寄る」と約束してしまいました。"),
        ("裏切られた心",
         "ところが安珍は再び彼女に会うつもりはなく、約束を反故にして寺へと急ぎます。清姫はその気配を感じ取り、裏切られた思いで胸をかきむしられるような怒りに燃えました。"),
        ("執念の追跡",
         "「騙された！」 清姫は走り、やがて人の力を超えた執念に突き動かされます。髪を振り乱し、裸足で野を駆け、やがてその姿は蛇へと変貌していきました。"),
        ("日高川の激流",
         "安珍は必死で日高川を船で渡ろうとします。けれども清姫は巨大な蛇と化し、川を泳ぎ渡り、火花を散らしながら彼を追いました。村人たちはその異様な姿に恐れ慄き、誰も止めることができませんでした。"),
        ("道成寺への逃げ込み",
         "ついに安珍は道成寺に辿り着き、僧たちに助けを求めます。僧たちは彼を大きな鐘の中に隠し、清姫の追撃から守ろうとしました。"),
        ("炎の執念",
         "やがて清姫は鐘の前に現れます。蛇の巨体で鐘に巻き付き、燃えさかる炎を吐きかけました。鐘は灼熱に包まれ、中に隠れた安珍は焼き殺されてしまいました。"),
        ("破滅ののち",
         "恋い焦がれた男を自らの手で死に追いやった清姫は、憎しみも恋心も飲み込んで炎の中に消えていきました。その姿は人のものではなく、執念に囚われた怪物そのものでした。"),
        ("伝説として残る",
         "この悲劇はやがて「道成寺縁起」として語り継がれ、能・歌舞伎・浄瑠璃などに取り上げられました。清姫の恋は純粋でありながら、執念によって悲劇に変わり、今もなお人々に強い印象を残しています。")
    ]
    
    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                ForEach(Array(sections.enumerated()),id:\.offset){ id ,item in
                    StorySectionNumber(colorName: .orange, numberString: "\(id+1)" ,title: item.title)
                    HStack{
                        Text(item.body)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom,8)
                }
            }
            .padding(12)
            .navigationTitle("安珍清姫")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem{
                    Button {
                        dismiss()
                    } label: {
                        Text("閉じる")
                    }
                }
            }
        }
    }
}
