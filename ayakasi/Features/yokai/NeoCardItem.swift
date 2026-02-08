import SwiftUI
import Kingfisher

struct NeoCardItem: View {
    let item: Ayakasi
    @EnvironmentObject var voteService : VoteService
    @EnvironmentObject var favoriteService : FavoriteService
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
                .font(.subheadline)
                .lineLimit(1)
                .fontWeight(.bold)
                .padding(.bottom,2)
            HStack(spacing: 4){
                HStack(spacing: 1){
                    Image(systemName: "heart")
                    Text("\(voteService.voteCountCache[item.documentId] ?? 0)")
                }

                Image(systemName: favoriteService.isFavoriteYokai(item.documentId) ? "star.fill" : "star")
                    .font(.system(size: 10))

                if item.sotry {
                    Image("book")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(.black)
                }

                Spacer()
            }
            .font(.caption)
        }
        .frame(width: 120)
    }
}
