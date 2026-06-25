import SwiftUI
import Kingfisher

struct NeoCardItem: View {
    let item: Ayakasi
    let onTap: () -> Void
    @EnvironmentObject var favoriteService: FavoriteService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // イメージエリア + メインエリア（タップで詳細遷移）
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {
                    // イメージエリア
                    GeometryReader { proxy in
                        ZStack {
                            if item.imageName == "NoImage" {
                                Color.gray.opacity(0.12)
                                VStack(spacing: 4) {
                                    Image(systemName: "questionmark.square")
                                        .font(.system(size: 32))
                                    Text("No Image")
                                        .font(.caption2)
                                }
                                .foregroundColor(.appTextSecondary)
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
                                    .frame(width: proxy.size.width, height: proxy.size.width)
                                    .clipped()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()

                    // メインエリア
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(.appTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 52)
                        .padding(.horizontal, 10)
                }
            }
            .buttonStyle(.plain)

            // サブエリア
            Button {
                favoriteService.toggleFavoriteYokai(item.documentId)
            } label: {
                Text(favoriteService.isFavoriteYokai(item.documentId) ? "ブックマーク済み" : "ブックマーク")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(favoriteService.isFavoriteYokai(item.documentId) ? .white : .appTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(favoriteService.isFavoriteYokai(item.documentId) ? Color.appSecondary : Color.clear)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(favoriteService.isFavoriteYokai(item.documentId) ? Color.clear : Color.appTextSecondary, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 2)
    }
}
