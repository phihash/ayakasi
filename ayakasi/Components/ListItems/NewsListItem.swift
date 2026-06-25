import SwiftUI

struct NewsListItem: View {
    let title: String
    let published: Date
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "newspaper")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: 24, height: 24)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 7) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    Text(publishedFormatter.string(from: published))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
