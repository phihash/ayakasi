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

    // 妖怪のお気に入り（ローカル保存）
    @Published var favoriteYokaiIds: [String] = [] {
        didSet {
            UserDefaults.standard.set(favoriteYokaiIds, forKey: "favoriteYokaiIds")
        }
    }
    
    @Published var readYokaiIds: [String] = [] {
        didSet {
            UserDefaults.standard.set(readYokaiIds, forKey: "readYokaiIds")
        }
    }

    // キャッシュ管理
    private let cacheValidDuration: TimeInterval = 300 // 5分
    @AppStorage("lastBookmarkFetch") private var lastBookmarkFetch: Double = 0

    private init(){
        // 保存されたお気に入りと既読を読み込む
        self.favoriteYokaiIds = UserDefaults.standard.stringArray(forKey: "favoriteYokaiIds") ?? []
        self.readYokaiIds = UserDefaults.standard.stringArray(forKey: "readYokaiIds") ?? []
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
    
    func fetchBookmarkComments() async throws {
        try await fetchBookmarkCommentIds()
        let commentIds = Array(bookmarkedCommentIds)
        
        guard !commentIds.isEmpty else {
            bookmarkedComments = []
            return
        }
        
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

    func isFavoriteYokai(_ documentId: String) -> Bool {
        return favoriteYokaiIds.contains(documentId)
    }

    func toggleFavoriteYokai(_ documentId: String) {
        if let index = favoriteYokaiIds.firstIndex(of: documentId) {
            favoriteYokaiIds.remove(at: index)
        } else {
            favoriteYokaiIds.append(documentId)
        }
    }
    
    func toggleReadYokai(_ documentId: String) {
        if let index = readYokaiIds.firstIndex(of: documentId) {
            readYokaiIds.remove(at: index)
        }else{
            readYokaiIds.append(documentId)
        }
    }

    func isReadYokai(_ documentId: String) -> Bool {
        return readYokaiIds.contains(documentId)
    }

}
