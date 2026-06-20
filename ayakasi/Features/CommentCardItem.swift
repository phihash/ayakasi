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
            .frame(width: 56, height: 56)
            .cornerRadius(8)
            .clipped()

            // メインエリア
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(yokaiName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextSecondary)

                    if let dateText {
                        Text(dateText)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()

                    if let currentUserId, let commentUserId,
                       currentUserId != commentUserId {
                        Button(action: onReport) {
                            Image(systemName: "ellipsis")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.appTextPrimary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
