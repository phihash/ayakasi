import SwiftUI
import os

enum MessageStatus: String, Decodable {
    case handled
    case inProgress
    case pending
}

/// Worker の GET /messages が返す1件(原本はD1の messages。管理画面から編集する)
struct Message: Identifiable, Decodable {
    let id = UUID()
    let content: String
    let status: MessageStatus
    let yearMonth: String  // 例: "2026.4"
    let note: String?

    private enum CodingKeys: String, CodingKey {
        case content, status, yearMonth, note
    }

    private static let yearMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M"
        return formatter
    }()

    static func hasNew(in messages: [Message]) -> Bool {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return messages.contains { message in
            guard let date = yearMonthFormatter.date(from: message.yearMonth) else { return false }
            return date >= oneMonthAgo
        }
    }

    // 失敗を空配列にするのは、設定画面のNEWバッジのために毎回取るので、通信できないだけでエラーを出したくないため
    static func fetchAll() async -> [Message] {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: AppConstants.messagesDataURL)!)
            return try JSONDecoder().decode([Message].self, from: data)
        } catch {
            Logger.data.error("みなさんの声の読み込み失敗: \(String(describing: error))")
            return []
        }
    }
}

struct MessageUI: View {
    /// 設定画面がNEWバッジのために取ったものを受け取る(開くたびに取り直さない)
    let messages: [Message]

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("公開OKのご意見のみ掲載しています")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)

                if messages.isEmpty {
                    Text("読み込めませんでした。通信状況を確認してください")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                }

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
            .navigationTitle("みなさんの声")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
