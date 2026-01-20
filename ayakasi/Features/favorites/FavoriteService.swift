import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FavoriteService : ObservableObject{
    static let shared = FavoriteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    @Published var bookmarkedCommentIds: [String] = []
    
    private init(){
        
    }
    
    @Published var isBookmarkCommentsLoading: Bool = false
    
    func fetchBookmarkComments() async throws {
        guard let userId = authService.currentUser?.uid else {return}
        
        isBookmarkCommentsLoading = true
        defer {isBookmarkCommentsLoading = false}
        
        let useRef = try await db.collection("users").document(userId).getDocument()
        bookmarkedCommentIds = useRef.get("bookmarkedComments") as? [String] ?? []
    }
    
    func bookmarkComments(_ commentId: String){
        
    }
    
}
