import SwiftUI

struct Yamanba: View {
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    private let sections: [(title: String, body: String)] = [
        ("坊主のおつかい",
         "あるお寺の坊主が、和尚さまに「山へ薪を取りに行け」と言われます。出かける前に和尚さまは「これを持っていけ」と 三枚のお札 を渡しました。"),
        ("優しいおばあさん",
         "山に入った坊主は、優しいおばあさんに出会います。日も暮れるし、うちに泊まっていきなさい」と言われ、安心して泊まることに。けれども、その正体は恐ろしい やまんば でした。"),
        ("便所のお札",
         "夜、やまんばは包丁を研ぎながら「坊主を食ってしまおう」と考えます。坊主は「便所へ」と願い出て、一枚目のお札を置き身代わりに返事をさせ、その隙に逃げ出しました。"),
        ("二枚目のお札 ― 大きな川",
         "追ってくるやまんば。坊主が二枚目のお札を投げると、目の前に大きな川が現れ、行く手をはばみます。"),
        ("三枚目のお札 ― 高い山",
         "それでもやまんばは川を渡って追ってきます。三枚目を投げると、高い山が立ちはだかり、足止めされました。"),
        ("寺に逃げ帰る",
         "坊主はどうにか寺まで逃げ帰りました。"),
        ("和尚の問いかけ",
         "追ってきたやまんばに、和尚さまは問います。「お前は大きくなれるか、小さくなれるか？」やまんばは得意げに「小さくもなれる」と体を縮めました。"),
        ("最後の仕掛けと結末",
         "その瞬間、和尚さまは餅の間にやまんばを挟み込み、ぱくり。こうして小坊主は助かり、やまんばは退治されました。")
    ]

    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                ForEach(Array(sections.enumerated()),id:\.offset){ id ,item in
                    StorySectionNumber(colorName: .storyPurple, numberString: "\(id+1)" ,title: item.title)
                    HStack{
                        Text(item.body)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom,8)
                }
            }
            .padding(12)
            .navigationTitle("やまんば")
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
