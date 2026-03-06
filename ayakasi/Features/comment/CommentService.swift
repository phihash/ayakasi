import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CommentError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
// 1.コメント一覧取得とブロックフィルタリング
//2.コメントをしたユーザーをブロックする
// 3.コメント投稿機能
// 4.コメント通報機能

@MainActor
class CommentService : ObservableObject {
    private let db = Firestore.firestore()

    // 定数
    private let maxRecentComments = 15
    private let cacheValidDuration: TimeInterval = 300 // 5分
    private let authService: AuthServiceProtocol
    private let commentTokenBucket: TokenBucketProtocol

    // キャッシュ管理
    @AppStorage("lastRecentCommentsFetch") private var lastRecentCommentsFetch: Double = 0
    
    init(authService: AuthServiceProtocol, tokenBucket: TokenBucketProtocol) {
        self.authService = authService
        self.commentTokenBucket = tokenBucket
    }
    
    //　TODOエラーを考える
    // 1.コメント一覧取得とブロックフィルタリング
    @Published var recentComments: [[String: Any]] = []
    @Published var isLoadingRecentComments = false
    
    func getRecentComments() async{
        isLoadingRecentComments = true
        do {
            let snapshot = try await db.collection("recentComments")
                .order(by: "createdAt", descending: true)
                .limit(to: maxRecentComments)
                .getDocuments()
            //QuerySnapshotのdocuments
            let comments = snapshot.documents.map{ document in
                var data = document.data()
                data["documentId"] = document.documentID
                return data
            }
            recentComments = await filterBlockedComments(comments)
            lastRecentCommentsFetch = Date().timeIntervalSince1970
            isLoadingRecentComments = false
        }catch{
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
    
    //ログインユーザー専用、その投稿をしたユーザーの投稿全てをブロックする。
    private func filterBlockedComments(_ comments: [[String: Any]]) async -> [[String: Any]] {
        guard let user = authService.currentUser else { return comments }
        
        var filteredComments: [[String: Any]] = []
        
        for comment in comments {
            if let userId = comment["userId"] as? String {
                let isBlocked = await isUserBlocked(userId: userId, user: user)
                if !isBlocked {
                    filteredComments.append(comment)
                }
            }
        }
        return filteredComments
    }
    
    //TODO　エラー処理を考える
    private func isUserBlocked(userId: String, user: User) async -> Bool {
        do {
            let userDoc = try await db.collection("users").document(user.uid).getDocument()
            let blockedUsers = userDoc.get("blockedUsers") as? [String] ?? []
            return blockedUsers.contains(userId)
        } catch {
            return true  // エラー時はブロックされているとする
        }
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
            
            yokaiComments = await filterBlockedComments(comments)
            isLoadingYokaiComments = false
        } catch {
            isLoadingYokaiComments = false
        }
    }
    
    //2、コメントをしたユーザーをブロックする
    func blockUser(userId: String) async throws {
        guard !userId.isEmpty else {
            throw CommentError(message: "無効なユーザーIDです")
        }
        //念の為
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
    
    //3 コメント投稿機能
    
    
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
    
    //4 コメント通報機能
    func reportRecentComment(documentId: String) async throws {
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
