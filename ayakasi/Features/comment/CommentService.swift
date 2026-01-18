import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CommentError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
// 1.コメント一覧取得
// 2.コメント投稿機能
// 3.コメント通報機能

@MainActor
class CommentService : ObservableObject {
    static let shared = CommentService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    // トークンバケット用のプロパティ
    @AppStorage("commentTokens") private var availableTokens: Int = 3
    @AppStorage("lastCommentRefillTime") private var lastRefillTime: Double = -1
    
    init() {// 初回起動時のみlastRefillTimeを現在時刻に設定
        if lastRefillTime == -1 {
            lastRefillTime = Date().timeIntervalSince1970
        }
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
                .limit(to: 15)
                .getDocuments()
            //QuerySnapshotのdocuments
            let comments = snapshot.documents.map{ document in
                var data = document.data()
                data["documentId"] = document.documentID
                return data
            }
            recentComments = await filterBlockedComments(comments)
            isLoadingRecentComments = false
        }catch{
            isLoadingRecentComments = false
        }
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

    private func getCurrentMaxTokens() -> Int {
        if authService.currentUser != nil {
            return 5  // ログイン済み: 最大5個
        } else {
            return 3   // 未ログイン: 最大3個
        }
    }
    
    private func refillToken() {
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastRefill = currentTime - lastRefillTime
        
        // 480秒（8分）ごとに1トークン
        let tokensToAdd = Int(timeSinceLastRefill / 480.0)
        
        if tokensToAdd > 0 {
            let currentMaxTokens = getCurrentMaxTokens()
            availableTokens = min(currentMaxTokens, tokensToAdd + availableTokens)
            lastRefillTime = currentTime
        }
    }
    
    private func canComment() -> Bool {
        refillToken()
        return availableTokens > 0
    }
    
    private func consumeToken() {
        if availableTokens > 0 {
            availableTokens -= 1
        }
    }

    func reportRecentComment(documentId: String) async throws {
        guard !documentId.isEmpty else {
            throw CommentError(message: "無効なコメントIDです")
        }

        guard await authService.ensureUserExists() else {
            throw CommentError(message: "ユーザー情報の取得に失敗しました")
        }

        guard let user = authService.currentUser else {
            throw CommentError(message: "ログインが必要です")
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
    
    func blockUser(userId: String) async throws {
        guard await authService.ensureUserExists() else {
            throw CommentError(message: "ユーザー情報の取得に失敗しました")
        }

        guard let user = authService.currentUser else {
            throw CommentError(message: "ログインが必要です")
        }

        let userRef = db.collection("users").document(user.uid)

        try await userRef.updateData([
            "blockedUsers": FieldValue.arrayUnion([userId])
        ])
    }
    
    //ここから





    
    //ここまで
    
    func postComment(content: String, yokai: Ayakasi) async throws {
        guard !content.isEmpty else {
            throw CommentError(message: "コメントが空です")
        }
        guard let user = authService.currentUser else {
            throw CommentError(message: "ログインが必要です")
        }
        // トークンバケットチェック
        guard canComment() else {
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
        consumeToken()
    }

    @Published var yokaiComments: [[String: Any]] = []
    @Published var isLoadingYokaiComments = false

    func fetchYokaiComments(yokaiId: String) async {
        print("🔍 fetchYokaiComments開始: \(yokaiId)")
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
            print("✅ コメント取得成功: \(yokaiComments.count)件")
            isLoadingYokaiComments = false
        } catch {
            print("❌ コメント取得エラー: \(error)")
            isLoadingYokaiComments = false
        }
    }
}
