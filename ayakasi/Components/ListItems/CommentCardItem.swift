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
        Button(action: onTap) {
            HStack(spacing: 12) {
                CommentThumbnail(imageURL: imageURL)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(yokaiName)
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                            .lineLimit(1)

                        if let dateText {
                            Text(dateText)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.appTextSecondary)
                                .lineLimit(1)
                        }
                    }

                    Text(content)
                        .font(.subheadline)
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let currentUserId, let commentUserId,
                   currentUserId != commentUserId {
                    Button(action: onReport) {
                        Image(systemName: "ellipsis")
                            .font(.body)
                            .foregroundColor(.appTextSecondary)
                            .frame(width: 32, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(12)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
}

private struct CommentThumbnail: View {
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
