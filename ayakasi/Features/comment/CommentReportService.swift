import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class CommentReportService: ObservableObject {
    private let db = Firestore.firestore()
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // コメントを通報する
    func reportComment(documentId: String) async throws {
        guard !documentId.isEmpty else {
            throw CommentError(message: "無効なコメントIDです")
        }

        guard let user = authService.currentUser else {
            throw CommentError(message: "ログインが必要です")
        }

        // コメントを取得して、自分のコメントかチェック
        let commentDoc = try await db.collection("recentComments").document(documentId).getDocument()
        guard let commentUserId = commentDoc.get("userId") as? String else {
            throw CommentError(message: "コメント情報の取得に失敗しました")
        }

        guard commentUserId != user.uid else {
            throw CommentError(message: "自分のコメントは報告できません")
        }

        // usersコレクションで既に報告済みかチェック
        let userDoc = try await db.collection("users").document(user.uid).getDocument()
        let reportedComments = userDoc.get("reportedComments") as? [String] ?? []

        guard !reportedComments.contains(documentId) else {
            throw CommentError(message: "既に報告済みです")
        }

        // recentCommentsを更新
        let commentRef = db.collection("recentComments").document(documentId)
        try await commentRef.updateData([
            "reportCount": FieldValue.increment(Int64(1)),
            "reportedBy": FieldValue.arrayUnion([user.uid])
        ])

        // usersを更新
        let userRef = db.collection("users").document(user.uid)
        try await userRef.updateData([
            "reportedComments": FieldValue.arrayUnion([documentId])
        ])
    }
}
