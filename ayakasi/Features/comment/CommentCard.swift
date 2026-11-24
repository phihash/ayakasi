import SwiftUI

struct CommentCard: View {
    let comment: YokaiComment
    var showsYokai = false
    let onChanged: () async -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if showsYokai, let yokai = yokaiById(comment.yokaiId) {
                NavigationLink(value: yokai) {
                    content(yokaiName: yokai.name, linksToDetail: true)
                }
                .buttonStyle(.plain)
                .accessibilityHint("妖怪の詳細を開きます")
            } else {
                content(yokaiName: showsYokai ? comment.yokaiId : nil)
            }

            // リンクの中に置くと、メニューを開くタップで妖怪詳細にも遷移してしまう。
            if !comment.isMine {
                CommentMenu(comment: comment, onDone: onChanged)
                    .padding(6)
            }
        }
        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
    }

    private func content(yokaiName: String?, linksToDetail: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let yokaiName {
                HStack {
                    Text(yokaiName)
                        .appFont(.subheadline, weight: .semibold)
                        .foregroundStyle(colorScheme == .dark ? Color.appPrimary : Color.appSecondary)
                    Spacer()
                    if linksToDetail {
                        Image(systemName: "chevron.right")
                            .appFont(.caption, weight: .semibold)
                            .foregroundStyle(Color.appTextSecondary)
                            .accessibilityHidden(true)
                    }
                }
            }

            Text(comment.content)
                .appFont(.body)
                .foregroundStyle(Color.appTextPrimary)
                .lineSpacing(3)
                .lineLimit(linksToDetail ? 3 : nil)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Text(comment.createdAt, format: .relative(presentation: .numeric))
                if comment.isWithdrawn {
                    Text("退会したユーザー")
                }
            }
            .appFont(.footnote)
            .foregroundStyle(Color.appTextSecondary)
            .padding(.trailing, comment.isMine ? 0 : 44)
            .frame(minHeight: 24, alignment: .leading)
        }
        .multilineTextAlignment(.leading)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
