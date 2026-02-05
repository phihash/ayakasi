import SwiftUI
import Kingfisher

struct NeoCardItem: View {
    @EnvironmentObject var voteService : VoteService
    let item = Ayakasi(
        name: "しろうかり",
        documentId: "siroukari",
        imageName: "https://i.imgur.com/KTuQ8yj.png",
        description: "百鬼夜行絵巻をはじめとした、絵巻物に描かれている妖怪\n白くて細長い妖怪で詳細は不明",
        categories: ["詳細不明","すべて"],
        relatedCategory: "詳細不明",
        btw: nil,
        searchKeywords: ["ばけ物つくし帖","百物語化絵絵巻","百鬼夜行絵巻","尾田郷澄","江戸時代"],
        sotry: false
    )
    var body: some View {
        VStack(alignment: .leading){
            KFImage(URL(string: item.imageName))
                .placeholder {
                    Image("loading")
                        .resizable()
                        .scaledToFill()
                }
                .cacheOriginalImage()
                .resizable()
                .scaledToFill()
                .frame(width: 120,height: 120)
                .cornerRadius(12)
            Text(item.name)
                .fontWeight(.bold)
            HStack(spacing: 4){
                Image(systemName: "heart")
                Text("\(voteService.voteCountCache[item.documentId] ?? 0)")
                Spacer()
            }
            .font(.caption)
        }
        .frame(width: 120)
    }
}
