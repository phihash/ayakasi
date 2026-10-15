import SwiftUI
import Kingfisher
import StoreKit

struct NeoCardItem: View {
    let item: Ayakasi
    let onTap: () -> Void
    @EnvironmentObject var favoriteService: FavoriteService
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // イメージエリア（タップで詳細遷移）
            Button(action: onTap) {
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
                                // 原画は1000px前後・平均1MBあり、一覧で原寸デコードするとメモリを食うので表示サイズに縮める(原画はディスクに残し詳細画面で使う)
                                .downsampling(size: CGSize(width: 200, height: 200))
                                .scaleFactor(UIScreen.main.scale)
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
            }
            .buttonStyle(.plain)

            // 名前（長ければ…で省略）+ ブックマーク（固定幅）
            HStack(spacing: 0) {
                Button(action: onTap) {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.appTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 52)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    let isAddingFavorite = !favoriteService.isFavoriteYokai(item.documentId)
                    let isFirstFavorite = isAddingFavorite && favoriteService.favoriteYokaiIds.isEmpty
                    favoriteService.toggleFavoriteYokai(item.documentId)
                    Analytics.trackFavoriteToggled(
                        yokaiName: item.name,
                        documentId: item.documentId,
                        isFavorite: isAddingFavorite
                    )

                    if isFirstFavorite,
                       ReviewRequestManager.shared.shouldRequestReviewAfterFirstFavorite() {
                        requestReview()
                    }
                } label: {
                    let isFav = favoriteService.isFavoriteYokai(item.documentId)
                    Image(systemName: isFav ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isFav ? .appSecondary : .appTextSecondary)
                        .frame(width: 36, height: 52)
                        .contentShape(Rectangle())
                        .accessibilityLabel(isFav ? "ブックマーク済み" : "ブックマーク")
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 10)
            .padding(.trailing, 4)
        }
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 2)
    }
}
