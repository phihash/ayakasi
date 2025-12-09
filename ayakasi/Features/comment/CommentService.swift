import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let content: String
    let createdAt: Date
    let isDeleted: Bool
    let deletedByAdmin: Bool
    let reportCount: Int
    let moderationStatus: String
    let appVersion: String?
    
    init(id: String, userId: String, userName: String, content: String, createdAt: Date = Date(), isDeleted: Bool = false, deletedByAdmin: Bool = false, reportCount: Int = 0, moderationStatus: String = "approved", appVersion: String? = nil) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.content = content
        self.createdAt = createdAt
        self.isDeleted = isDeleted
        self.deletedByAdmin = deletedByAdmin
        self.reportCount = reportCount
        self.moderationStatus = moderationStatus
        self.appVersion = appVersion
    }
}

@MainActor
class CommentService : ObservableObject {
    static let shared = CommentService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    
    @Published var commentNow : String = ""
}
