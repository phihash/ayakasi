import SwiftUI

struct Yuki: View {
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    private let sections: [(title: String, body: String)] = [
          ("冬の夜の出来事",
           "ある雪の深い夜、木こりの親子は山中で猛吹雪に遭い、小屋へ避難しました。そこで二人を訪れたのが、真っ白な着物に身を包み、氷のように冷たい息を持つ「雪女」でした。"),
          ("息子への慈悲",
           "雪女は父をその冷気で殺してしまいますが、若い息子には「このことを誰にも話さなければ命を助ける」と言い残し、消えていきました。息子は恐怖に震えながらも、その約束を心に刻みます。"),
          ("美しい娘との出会い",
           "しばらくして、息子は「お雪」という名の美しい娘と出会い、やがて夫婦となります。二人の生活は幸せに満ち、子どもにも恵まれました。"),
          ("禁じられた告白",
           "ある冬の晩、息子はふとあの夜の出来事を思い出し、妻に語ってしまいます。「昔、雪女に出会って父を殺され、命を助けられたんだ……」"),
          ("正体の発覚",
           "それを聞いた妻は顔色を変え、次の瞬間に姿を変えました。「約束を破るとは……私はその雪女だ」。お雪は子どもたちを思い、「子どもたちがいるから今日は命を奪わない」と言い残し、吹雪の夜に消えていきました。"),
          ("その後",
           "雪女は二度と現れず、残されたのは子どもたちと、深い雪の記憶だけでした。")
      ]

    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                ForEach(Array(sections.enumerated()),id:\.offset){ id ,item in
                    StorySectionNumber(colorName: .storyBlue, numberString: "\(id+1)" ,title: item.title)
                    HStack{
                        Text(item.body)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom,8)
                }
            }
            .padding(12)
            .navigationTitle("雪女")
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
