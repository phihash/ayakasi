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
    
    @Published var isBookmarkCommentsLoafing: Bool = false
    
    func fetchBookmarkComments() async throws {
        guard let userId = authService.currentUser?.uid else {return}
        
        isBookmarkCommentsLoafing = true
        defer {isBookmarkCommentsLoafing = false}
        
        let useRef = try await db.collection("users").document(userId).getDocument()
        let bookmarkComments = useRef.get("bookmarkCommentIds") as? [String] ?? []
        
    }
    
    func bookmarkComments(_ commentId: String){
        
    }
    
}
