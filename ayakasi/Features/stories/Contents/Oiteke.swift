import SwiftUI

struct Oiteke: View {
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    private let sections: [(title: String, body: String)] = [
        ("博打にのめり込む男",
         "昔ある所に一人の男がおりました。その男は博打を覚えてしまいまったく働こうとしませんでした。家業もそっちのけで、毎日賭場に通う日々でした。"),
        ("幼馴染みの心配",
         "見兼ねた幼馴染みが何度も働くよう説得しましたが、男は全く聞き入れません。このままでは身を滅ぼすと心配し、ある計画を思いつきました。"),
        ("危険な賭けの提案",
         "幼馴染は男と賭けをすることにしました。「おいてけ堀」で夜釣りをして、魚を持って帰って来れたらもう何も言わないと約束したのです。"),
        ("おいてけ堀の噂",
         "この街には「おいてけ堀」という堀がありました。夜釣りをすると「おいてけ〜…」という声がして、化け物が現れるという恐ろしい噂のある場所でした。"),
        ("恐怖の夜釣り",
         "その夜、男はおいてけ堀で釣りをしていました。静寂な夜の中、釣り糸を垂らしながら、噂の化け物など現れないだろうと高をくくっていました。"),
        ("不気味な声",
         "すると堀の方から「おいてけ〜…」という不気味な声が聞こえてきました。男はびっくりして逃げ出そうとしましたが、そこに一人の美しい若い女が現れたのです。"),
        ("のっぺらぼうの正体",
         "女は男を見ると「今ここで釣った魚を置いて行ってください」と言って、自分の顔をはずしました。そこには何も無い、のっぺらぼうの顔があったのです。"),
        ("ソバ屋での恐怖",
         "男がいつも通っている店へ逃げ込み、おやじに今のことを話しました。すると「それはこんな顔ではなかったか？」とおやじが振り返ると、その顔ものっぺらぼうでした。"),
        ("家でも続く悪夢",
         "男は釣った魚も何も放り出して家へ逃げ帰りました。女房が「お帰り」と言って振り返ると、女房の顔ものっぺらぼうだったのです。男は恐怖のあまり気絶してしまいました。"),
        ("友人たちの芝居",
         "実は「おいてけ〜…」の声は幼馴染で、ソバ屋のおやじと男の女房は白粉を塗ってのっぺらぼうに化けていました。男を立ち直らせるため、みんなで一芝居打ったのです。"),
        ("本当の化け物",
         "しかし、あの美しい女性は誰も頼んでいませんでした。本当においてけ堀には化け物がいたのです。二人は青ざめ、男は心を入れ替えて真面目に働くようになったということです。")
    ]
    
    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                ForEach(Array(sections.enumerated()),id:\.offset){ id ,item in
                    StorySectionNumber(colorName: .red, numberString: "\(id+1)" ,title: item.title)
                    HStack{
                        Text(item.body)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom,8)
                }
            }
            .padding(12)
            .navigationTitle("おいてけ掘")
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
