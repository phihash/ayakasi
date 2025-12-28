import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

//struct Comment: Identifiable, Codable {
//    let id: String !
//    let userId: String !
//    let userName: String
//    let content: String !
//    let createdAt: Date !
//    let isDeleted: Bool
//    let deletedByAdmin: Bool
//    let reportCount: Int
//    let moderationStatus: String
//    let appVersion: String?
//    
//    init(id: String, userId: String, userName: String, content: String, createdAt: Date = Date(), isDeleted: Bool = false, deletedByAdmin: Bool = false, reportCount: Int = 0, moderationStatus: String = "approved", appVersion: String? = nil) {
//        self.id = id
//        self.userId = userId
//        self.userName = userName
//        self.content = content
//        self.createdAt = createdAt
//        self.isDeleted = isDeleted
//        self.deletedByAdmin = deletedByAdmin
//        self.reportCount = reportCount
//        self.moderationStatus = moderationStatus
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
    @AppStorage("lastCommentFetch") private var lastFetchTimestamp: Double = 0
    
    private func isWithinFiveMinutes() -> Bool {
        let now = Date().timeIntervalSince1970
        let fiveMinutesInSeconds = TimeInterval(5 * 60)
        return (now - lastFetchTimestamp) < fiveMinutesInSeconds
    }
    
    func getRecentComments() async{
        isLoadingRecentComments = true
        do {
            let snapshot = try await db.collection("recentComments")
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .getDocuments()
            
            recentComments = snapshot.documents.map{
                $0.data()
            }
  
            isLoadingRecentComments = false
        }catch{
            isLoadingRecentComments = false
        }
    }
    
    func postComment(yokai: Ayakasi) async {
        guard !commentNow.isEmpty else { return }
        guard let user = authService.currentUser else { return }
        
        let commentData = [
            "yokaiId": yokai.documentId,
            "userId": user.uid,
            "content": commentNow,
            "createdAt": FieldValue.serverTimestamp()
        ] as [String : Any]
        
        // recentComments用のデータ
        let recentCommentData = [
            "yokaiId": yokai.documentId,
            "yokaiName": yokai.name,
            "userId": user.uid,
            "userName": user.displayName ?? "匿名ユーザー",
            "content": commentNow,
            "createdAt": FieldValue.serverTimestamp()
        ] as [String : Any]
        
        do {
            // 1. 妖怪別コメントに保存
            try await db.collection("comments")
                .document(yokai.documentId)
                .collection("userComments")
                .addDocument(data: commentData)
            
            // 2. 最新コメント一覧に保存
            try await db.collection("recentComments")
                .addDocument(data: recentCommentData)
            
            commentNow = ""
            isCommentUI = false
            print("✅ コメント投稿成功（二重管理）")
        } catch {
            print("❌ 投稿失敗: \(error)")
        }
    }
}
