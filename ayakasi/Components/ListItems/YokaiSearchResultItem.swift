import SwiftUI
import Kingfisher

struct YokaiSearchResultItem: View {
    let yokai: Ayakasi
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                YokaiSearchThumbnail(imageURL: yokai.imageName)

                VStack(alignment: .leading, spacing: 4) {
                    Text(yokai.name)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)

                    Text(yokai.categories.joined(separator: "・"))
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            .padding(12)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct YokaiSearchThumbnail: View {
    let imageURL: String

    var body: some View {
        Group {
            if imageURL != "NoImage", let url = URL(string: imageURL) {
                KFImage(url)
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
            } else {
                ZStack {
                    Color.gray.opacity(0.12)
                    Image(systemName: "questionmark.square")
                        .font(.system(size: 18))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
