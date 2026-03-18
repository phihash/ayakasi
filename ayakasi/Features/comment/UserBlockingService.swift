import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class UserBlockingService: ObservableObject {
    private let db = Firestore.firestore()
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // ユーザーがブロック済みかチェック
    func isUserBlocked(userId: String) async -> Bool {
        guard let user = authService.currentUser else { return false }

        do {
            let userDoc = try await db.collection("users").document(user.uid).getDocument()
            let blockedUsers = userDoc.get("blockedUsers") as? [String] ?? []
            return blockedUsers.contains(userId)
        } catch {
            return true  // エラー時はブロックされているとする
        }
    }

    // ユーザーをブロックする
    func blockUser(userId: String) async throws {
        guard !userId.isEmpty else {
            throw CommentError(message: "無効なユーザーIDです")
        }

        guard let user = authService.currentUser else {
            throw CommentError(message: "ログインが必要です")
        }

        // 自分自身をブロックできないようにする
        guard userId != user.uid else {
            throw CommentError(message: "自分自身をブロックすることはできません")
        }

        // 既にブロック済みかチェック
        let userDoc = try await db.collection("users").document(user.uid).getDocument()
        let blockedUsers = userDoc.get("blockedUsers") as? [String] ?? []

        guard !blockedUsers.contains(userId) else {
            throw CommentError(message: "既にブロック済みです")
        }

        try await db.collection("users").document(user.uid).updateData([
            "blockedUsers": FieldValue.arrayUnion([userId])
        ])
    }

    // コメント配列をフィルタリング（ブロックユーザーの投稿を除外）
    func filterBlockedComments(_ comments: [[String: Any]]) async -> [[String: Any]] {
        guard authService.currentUser != nil else { return comments }

        var filteredComments: [[String: Any]] = []

        for comment in comments {
            if let userId = comment["userId"] as? String {
                let isBlocked = await isUserBlocked(userId: userId)
                if !isBlocked {
                    filteredComments.append(comment)
                }
            }
        }
        return filteredComments
    }
}
