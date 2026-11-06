import SwiftUI

struct NewsListItem: View {
    let title: String
    let published: Date
    let image: URL?
    let phrases: [String]?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ListCard(image: image, systemImage: "newspaper", title: title, phrases: phrases) {
                Text(publishedFormatter.string(from: published))
                    .appFont(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}
