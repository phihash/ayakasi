import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isHandled: Bool
    let yearMonth: String  // 例: "2026.4"
}

struct MessageUI: View {
    @State private var messages: [Message] = [
        Message(
            content: "新しい妖怪を追加して欲しい、1 ぬっぺっほふ 2 けうけげん 3 さんもとごぶろうざえもん",
            isHandled: true,
            yearMonth: "2026.4"
        ),
        Message(
            content: "「だいだらぼっち」と「烏天狗（からすてんぐ）」と「手長&足長」と「じんめんじゅ」と「天邪鬼」と「送り提灯」お願いします！",
            isHandled: true,
            yearMonth: "2026.4"
        ),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("公開OKのご意見のみ掲載しています")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(message.content)
                                .font(.body)
                                .foregroundColor(.primary)

                            HStack {
                                Text(message.yearMonth)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                if message.isHandled {
                                    Label("対応済み", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .navigationTitle("みなさんの声から")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
