import SwiftUI
import Kingfisher

struct CardUI: View {
    let imageURL: String?
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // イメージエリア
                GeometryReader { proxy in
                    ZStack {
                        if let imageURL, imageURL != "NoImage", let url = URL(string: imageURL) {
                            KFImage(url)
                                .placeholder {
                                    Image("loading")
                                        .resizable()
                                        .scaledToFill()
                                }
                                .cacheOriginalImage()
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                        } else {
                            Color.gray.opacity(0.12)
                            VStack(spacing: 4) {
                                Image(systemName: "questionmark.square")
                                    .font(.system(size: 32))
                                Text("No Image")
                                    .font(.caption2)
                            }
                            .foregroundColor(.appTextSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()

                // メインエリア
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
