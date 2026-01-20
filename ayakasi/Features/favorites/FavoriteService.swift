import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FavoriteService : ObservableObject{
    static let shared = FavoriteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    @Published var bookmarkedCommentIds: Set<String> = []
    
    private init(){
        
    }
    
    @Published var isBookmarkCommentsLoading: Bool = false
    
    func fetchBookmarkComments() async throws {
        guard let userId = authService.currentUser?.uid else {return}
        
        isBookmarkCommentsLoading = true
        defer {isBookmarkCommentsLoading = false}
        
        let useRef = try await db.collection("users").document(userId).getDocument()
        let commentIds = useRef.get("bookmarkedComments") as? [String] ?? []
        bookmarkedCommentIds = Set(commentIds)
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
