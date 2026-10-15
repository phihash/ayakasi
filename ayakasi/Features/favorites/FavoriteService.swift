import SwiftUI

@MainActor
class FavoriteService : ObservableObject{
    static let shared = FavoriteService()

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
