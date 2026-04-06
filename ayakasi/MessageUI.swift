import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isHandled: Bool
}

struct MessageUI: View {
    @State private var messages: [Message] = [
        Message(
            content: "新しい妖怪を追加して欲しい、1 ぬっぺっほふ 2 けうけげん 3 さんもとごぶろうざえもん",
            isHandled: true
        )
    ]

    var body: some View {
        NavigationStack {
            Text("公開していいとチェックしていただいたものを表示しています")
                .font(.subheadline)
                .padding(.vertical,8)
            List(messages) { message in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {

                        Spacer()

                        if message.isHandled {
                            Image(systemName: "checkmark")
                        }
                    }

                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
            }
            .navigationTitle("お問い合わせ一覧")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
