import SwiftUI

enum MessageStatus {
    case handled
    case inProgress
    case pending
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let status: MessageStatus
    let yearMonth: String  // 例: "2026.4"
    let note: String?
}

struct MessageUI: View {
    @State private var messages: [Message] = [
        Message(
            content: "新しい妖怪を追加して欲しい、1 ぬっぺっほふ 2 けうけげん 3 さんもとごぶろうざえもん",
            status: .handled,
            yearMonth: "2026.4",
            note: nil
        ),
        Message(
            content: "「だいだらぼっち」と「烏天狗（からすてんぐ）」と「手長&足長」と「じんめんじゅ」と「天邪鬼」と「送り提灯」お願いします！",
            status: .handled,
            yearMonth: "2026.4",
            note: nil
        ),
        Message(
            content: "以津真天（いつまで）と「遊人（あそびび）」と「鬼火（おにび）」と猩々（しょうじょう）と「ガラッパ」と「髪切り（かみきり）」と「油引小僧」と「雷獣」お願いします！",
            status: .handled,
            yearMonth: "2026.4",
            note: "以津真天・遊火・鬼火・猩々・髪切り・雷獣は対応しました。「遊人（あそびび）」は高知県に伝わる怪火「遊火（あそびび）」のことと解釈して追加しました。「油引小僧」は「袖引小僧（そでひきこぞう）」のことと思われますが、パブリックドメインの画像が見つからず、ガラッパも同様の理由で保留にさせていただいております🙇‍♂️"
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

                            if let note = message.note {
                                Text(note)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 2)
                            }

                            HStack {
                                Text(message.yearMonth)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                switch message.status {
                                case .handled:
                                    Label("対応済み", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                case .inProgress:
                                    Label("対応中", systemImage: "clock.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                case .pending:
                                    EmptyView()
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
