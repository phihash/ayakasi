import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CommentError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

@MainActor
class CommentService : ObservableObject {
    private let db = Firestore.firestore()

    // 定数
    private let maxRecentComments = 15
    private let cacheValidDuration: TimeInterval = 300 // 5分
    private let authService: AuthServiceProtocol
    private let commentTokenBucket: TokenBucketProtocol
    private let blockingService: UserBlockingService

    // キャッシュ管理
    @AppStorage("lastRecentCommentsFetch") private var lastRecentCommentsFetch: Double = 0

    init(authService: AuthServiceProtocol, tokenBucket: TokenBucketProtocol, blockingService: UserBlockingService) {
        self.authService = authService
        self.commentTokenBucket = tokenBucket
        self.blockingService = blockingService
    }

    // コメント一覧取得とブロックフィルタリング
    @Published var recentComments: [[String: Any]] = []
    @Published var isLoadingRecentComments = false

    func getRecentComments() async {
        isLoadingRecentComments = true
        do {
            let snapshot = try await db.collection("recentComments")
                .order(by: "createdAt", descending: true)
                .limit(to: maxRecentComments)
                .getDocuments()

            let comments = snapshot.documents.map { document in
                var data = document.data()
                data["documentId"] = document.documentID
                return data
            }

            recentComments = await blockingService.filterBlockedComments(comments)
            lastRecentCommentsFetch = Date().timeIntervalSince1970
            isLoadingRecentComments = false
        } catch {
            isLoadingRecentComments = false
        }
    }

    func getRecentCommentsIfNeeded() async {
        let currentTime = Date().timeIntervalSince1970

        // キャッシュが有効なら再取得しない
        if currentTime - lastRecentCommentsFetch < cacheValidDuration {
            return
        }

        await getRecentComments()
    }


    @Published var yokaiComments: [[String: Any]] = []
    @Published var isLoadingYokaiComments = false

    func fetchYokaiComments(yokaiId: String) async {
        isLoadingYokaiComments = true
        do {
            let snapshot = try await db.collection("recentComments")
                .whereField("yokaiId", isEqualTo: yokaiId)
                .order(by: "createdAt", descending: false)
                .getDocuments()
            let comments = snapshot.documents.map { document in
                var data = document.data()
                data["documentId"] = document.documentID
                return data
            }

            yokaiComments = await blockingService.filterBlockedComments(comments)
            isLoadingYokaiComments = false
        } catch {
            isLoadingYokaiComments = false
        }
    }

    // コメント投稿機能


    func postComment(content: String, yokai: Ayakasi) async throws {
        guard !content.isEmpty else {
            throw CommentError(message: "コメントが空です")
        }
        guard let user = authService.currentUser else {
            throw CommentError(message: "ログインが必要です")
        }
        // トークンバケットチェック
        guard commentTokenBucket.canConsume() else {
            throw CommentError(message: "コメント回数の上限に達しました。しばらく待って再度お試しください。")
        }

        // recentComments（正コレクション）用のデータ
        let recentCommentData = [
            "yokaiId": yokai.documentId,
            "yokaiName": yokai.name,
            "userId": user.uid,
            "content": content,
            "createdAt": FieldValue.serverTimestamp(),
            "status": "pending",
            "reportCount": 0,
            "reportedBy": []
        ] as [String : Any]

        // 最新コメント一覧（= 正コレクション）に保存
        try await db.collection("recentComments")
            .addDocument(data: recentCommentData)
        // 成功時のみトークンを消費
        commentTokenBucket.consume()
    }
}
