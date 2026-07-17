import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FavoriteService : ObservableObject{
    static let shared = FavoriteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    @Published var bookmarkedCommentIds: Set<String> = []
    @Published var isBookmarkCommentsLoading: Bool = false

    // 妖怪のブックマーク（既存データ互換のためキー名はfavoriteのまま）
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
        // 保存されたブックマークと既読を読み込む
        self.favoriteYokaiIds = UserDefaults.standard.stringArray(forKey: "favoriteYokaiIds") ?? []
        self.readYokaiIds = UserDefaults.standard.stringArray(forKey: "readYokaiIds") ?? []
        ReviewRequestManager.shared.registerExistingFavoriteIfNeeded(
            hasFavorites: !favoriteYokaiIds.isEmpty
        )
    }

    
    func fetchBookmarkCommentIds() async throws {
        guard let user = authService.currentUser, user.isEmailVerified else { return }
        let userId = user.uid
        
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
