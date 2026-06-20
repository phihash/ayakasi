import SwiftUI
import Kingfisher

struct CommentCardItem: View {
    let content: String
    let yokaiName: String
    let imageURL: String
    let dateText: String?
    let currentUserId: String?
    let commentUserId: String?
    let onTap: () -> Void
    let onReport: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // イメージエリア
            Group {
                if imageURL != "NoImage", let url = URL(string: imageURL) {
                    KFImage(url)
                        .placeholder {
                            Image("loading")
                                .resizable()
                                .scaledToFill()
                        }
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color.gray.opacity(0.12)
                        Image(systemName: "questionmark.square")
                            .font(.system(size: 20))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            // メインエリア
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(yokaiName)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)

                    if let dateText {
                        Text(dateText)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }

                    Text(content)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.appTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(.plain)

            if let currentUserId, let commentUserId,
               currentUserId != commentUserId {
                Button(action: onReport) {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundColor(.appTextSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appCardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.appTextSecondary, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}
