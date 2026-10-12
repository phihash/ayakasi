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

    private init(){
        // 保存されたブックマークを読み込む
        self.favoriteYokaiIds = UserDefaults.standard.stringArray(forKey: "favoriteYokaiIds") ?? []
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

}
