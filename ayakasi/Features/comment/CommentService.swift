import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
    @Published var isLoadingYokaiComments = false
    @Published var yokaiComments: [[String: Any]] = []
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
                .limit(to: 15)
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
        print("🚀 postComment開始")
        guard !commentNow.isEmpty else { 
            print("❌ コメントが空")
            return 
        }
        guard let user = authService.currentUser else { 
            print("❌ ユーザー未認証")
            return 
        }
        
        print("✅ ユーザー認証OK: \(user.uid)")
        
        // トークンバケットチェック
        guard canComment() else {
            print("❌ トークン不足")
            alertMessage = "コメント回数の上限に達しました。しばらく待って再度お試しください。"
            showAlert = true
            return
        }
        
        print("✅ トークンOK")
        
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
            print("📤 Firestoreに送信中...")
            // 最新コメント一覧（= 正コレクション）に保存
            try await db.collection("recentComments")
                .addDocument(data: recentCommentData)
            
            print("✅ Firestore送信成功")
            
            // 成功時のみトークンを消費
            consumeToken()
            print("✅ トークン消費完了")
            
            await MainActor.run {
                print("🎬 UI更新開始")
                commentNow = ""
                isCommentUI = false
                // アラートを表示しない（シートが閉じるだけで十分）
                print("🎬 UI更新完了")
            }
            print("✅ postComment完了")
        } catch {
            print("❌ postCommentエラー: \(error)")
            alertMessage = "投稿に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func fetchYokaiComments(yokaiId: String) async {
        print("🔍 fetchYokaiComments開始: \(yokaiId)")
        isLoadingYokaiComments = true
        do {
            let snapshot = try await db.collection("recentComments")
                .whereField("yokaiId", isEqualTo: yokaiId)
                .getDocuments()
            yokaiComments = snapshot.documents.map { document in
                var data = document.data()
                data["documentId"] = document.documentID
                return data
            }
            print("✅ コメント取得成功: \(yokaiComments.count)件")
            isLoadingYokaiComments = false
        } catch {
            print("❌ コメント取得エラー: \(error)")
            isLoadingYokaiComments = false
        }
    }
}
