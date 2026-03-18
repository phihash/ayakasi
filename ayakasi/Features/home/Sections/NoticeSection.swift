import SwiftUI

struct NoticeSection: View {
    let notice: NoticeItem

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "megaphone")
                    .foregroundColor(.appPrimary)
                Text(notice.message)
                    .font(.body)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(Color.appPrimary.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}
