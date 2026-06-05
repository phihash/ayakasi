import SwiftUI
import Kingfisher

struct NeoCardItem: View {
    let item: Ayakasi
    @EnvironmentObject var voteService : VoteService
    @EnvironmentObject var favoriteService : FavoriteService
    var body: some View {
        VStack(alignment: .leading){
            Group {
                if item.imageName == "NoImage" {
                    VStack(spacing: 4) {
                        Image(systemName: "questionmark.square")
                            .font(.system(size: 32))
                        Text("No Image")
                            .font(.caption2)
                    }
                    .foregroundColor(.appTextSecondary)
                    .frame(width: 120, height: 120)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(12)
                } else {
                    KFImage(URL(string: item.imageName))
                        .placeholder {
                            Image("loading")
                                .resizable()
                                .scaledToFill()
                        }
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .cornerRadius(12)
                }
            }
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

                if let relatedSpots = item.relatedSpots, !relatedSpots.isEmpty {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.appSecondary)
                }

                if item.story {
                    Image("book")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.appTextPrimary)
                }

                Spacer()
            }
            .font(.caption)
        }
        .foregroundColor(Color.appTextPrimary)
        .frame(width: 120)
    }
}
