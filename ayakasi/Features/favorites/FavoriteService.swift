import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FavoriteService : ObservableObject{
    static let shared = FavoriteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    @Published var bookmarkedCommentIds: Set<String> = []
    @Published var bookmarkedComments: [[String: Any]] = []
    @Published var isBookmarkCommentsLoading: Bool = false
    
    // キャッシュ管理
    private let cacheValidDuration: TimeInterval = 300 // 5分
    @AppStorage("lastBookmarkFetch") private var lastBookmarkFetch: Double = 0
    
    private init(){
        
    }
    
    
    func fetchBookmarkCommentIds() async throws {
        guard let userId = authService.currentUser?.uid else {return}
        
        isBookmarkCommentsLoading = true
        defer {isBookmarkCommentsLoading = false}
        
        let useRef = try await db.collection("users").document(userId).getDocument()
        let commentIds = useRef.get("bookmarkedComments") as? [String] ?? []
        bookmarkedCommentIds = Set(commentIds)
        lastBookmarkFetch = Date().timeIntervalSince1970
    }
    
    func fetchBookmarkCommentIdsIfNeeded() async {
        let currentTime = Date().timeIntervalSince1970

        // キャッシュが有効なら再取得しない
        if currentTime - lastBookmarkFetch < cacheValidDuration {
            return
        }

        try? await fetchBookmarkCommentIds()
    }
    
    func bookmarkComments(_ commentId: String)async throws{
        guard let userId = authService.currentUser?.uid else {return}
        
        let isBookmarked = bookmarkedCommentIds.contains(commentId)
        
        if isBookmarked{
            try await db.collection("users").document(userId).updateData(
                ["bookmarkedComments": FieldValue.arrayRemove([commentId])]
            )
            bookmarkedCommentIds.remove(commentId)
        } else{
            try await db.collection("users").document(userId).updateData(
                ["bookmarkedComments": FieldValue.arrayUnion([commentId])]
            )
            bookmarkedCommentIds.insert(commentId)
        }
    }
    
}
