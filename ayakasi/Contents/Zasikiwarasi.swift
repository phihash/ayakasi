import SwiftUI

struct Zasikiwarasi: View {
    let screenWidth = UIScreen.main.bounds.width
    @EnvironmentObject var colorVM : ColorViewModel
    @Environment(\.dismiss) private var dismiss
    private let sections: [(title: String, body: String)] = [
        ("東北の古い家",
         "むかし、岩手や青森の山あいの村に、古くから立つ大きな家がありました。その家では、夜になると廊下を走る子どもの足音が聞こえることがありました。"),
        ("子どもの姿",
         "ある晩、家の主人がふと座敷を見ると、赤い小袖を着た小さな子どもがちょこんと座っていました。「誰の子だろう？」と思った瞬間、ふっと消えてしまいました。"),
        ("家に宿る守り神",
         "村人たちは「ああ、それは座敷わらしだ」と言いました。座敷わらしがいる家は栄え、商売も繁盛し、家族は幸せになると伝えられていたのです。"),
        ("去っていく時",
         "けれども、ある時期を境に足音も姿も消えてしまいました。すると不思議なことに、その家はだんだんと傾き、商売もうまくいかなくなっていったといいます。"),
        ("ありがたき存在",
         "人々は「座敷わらしは、幸せを運んでくれる子どもの神さまのような存在なのだ」と噂しました。今も東北の古民家を訪れると、座敷わらしに会えたら幸運が訪れると信じられています。")
    ]

    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                ForEach(Array(sections.enumerated()),id:\.offset){ id ,item in
                    StorySectionNumber(colorName: .green, numberString: "\(id+1)" ,title: item.title)
                    HStack{
                        Text(item.body)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom,8)
                }
            }
            .padding(12)
            .navigationTitle("座敷わらし")
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
