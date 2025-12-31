import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

//struct Comment: Identifiable, Codable {
//    let id: String !
//    let userId: String !
//    let userName: String
//    let isDeleted: Bool
//    let deletedByAdmin: Bool
//    let appVersion: String?
//        self.deletedByAdmin = deletedByAdmin
//        self.appVersion = appVersion
//    }
//}

@MainActor
class CommentService : ObservableObject {
    static let shared = CommentService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    
    @Published var commentNow : String = ""
    @Published var isCommentUI : Bool = false
    @Published var recentComments: [[String: Any]] = []
    @Published var isLoadingRecentComments = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @AppStorage("lastCommentFetch") private var lastFetchTimestamp: Double = 0
    
    // トークンバケット用のプロパティ
    @AppStorage("commentTokens") private var availableTokens: Int = 3
    @AppStorage("lastCommentRefillTime") private var lastRefillTime: Double = -1
    private var reportedCommentIds: [String] {
        get { UserDefaults.standard.stringArray(forKey: "reportedCommentIds") ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "reportedCommentIds") }
    }
    
    init() {
        // 初回起動時のみlastRefillTimeを現在時刻に設定
        if lastRefillTime == -1 {
            lastRefillTime = Date().timeIntervalSince1970
        }
    }
    
    private func isWithinFiveMinutes() -> Bool {
        let now = Date().timeIntervalSince1970
        let fiveMinutesInSeconds = TimeInterval(5 * 60)
        return (now - lastFetchTimestamp) < fiveMinutesInSeconds
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
    
    private func hasReported(commentId: String) -> Bool {
        return reportedCommentIds.contains(commentId)
    }
    
    private func markAsReported(commentId: String) {
        var ids = reportedCommentIds
        ids.append(commentId)
        reportedCommentIds = ids
    }
    
    func reportRecentComment(documentId: String) async {
        guard !documentId.isEmpty else {
            alertMessage = "無効なコメントIDです"
            showAlert = true
            return
        }
        
        if hasReported(commentId: documentId) {
            alertMessage = "既に報告済みです"
            showAlert = true
            return
        }
        
        do {
            let commentRef = db.collection("recentComments").document(documentId)
            
            try await commentRef.updateData([
                "reportCount": FieldValue.increment(Int64(1))
            ])
            
            markAsReported(commentId: documentId)
            
            alertMessage = "報告が完了しました"
            showAlert = true
            
        } catch {
            alertMessage = "報告に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    
    func getRecentComments() async{
        isLoadingRecentComments = true
        do {
            let snapshot = try await db.collection("recentComments")
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .getDocuments()
            
            recentComments = snapshot.documents.map{ document in
                var data = document.data()
                data["documentId"] = document.documentID
                return data
            }
            
            isLoadingRecentComments = false
        }catch{
            isLoadingRecentComments = false
        }
    }
    
    func postComment(yokai: Ayakasi) async {
        guard !commentNow.isEmpty else { return }
        guard let user = authService.currentUser else { return }
        
        // トークンバケットチェック
        guard canComment() else {
            alertMessage = "コメント回数の上限に達しました。しばらく待って再度お試しください。"
            showAlert = true
            return
        }
        
        // recentComments（正コレクション）用のデータ
        let recentCommentData = [
            "yokaiId": yokai.documentId,
            "yokaiName": yokai.name,
            "userId": user.uid,
            "content": commentNow,
            "createdAt": FieldValue.serverTimestamp(),
            "status": "pending",
            "reportCount": 0
        ] as [String : Any]
        
        do {
            // 最新コメント一覧（= 正コレクション）に保存
            try await db.collection("recentComments")
                .addDocument(data: recentCommentData)
            
            // 成功時のみトークンを消費
            consumeToken()
            
            commentNow = ""
            isCommentUI = false
            alertMessage = "コメントを投稿しました"
            showAlert = true
        } catch {
            alertMessage = "投稿に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
