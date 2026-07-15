import Foundation

final class ReviewRequestManager {
    static let shared = ReviewRequestManager()

    private let viewedYokaiIdsKey = "reviewViewedYokaiIds"
    private let hasAddedFavoriteKey = "hasAddedFavorite"
    private let hasRequestedReviewKey = "hasRequestedReview"

    private init() {}

    private var viewedYokaiIds: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: viewedYokaiIdsKey) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: viewedYokaiIdsKey)
        }
    }

    func recordYokaiViewed(documentId: String) {
        var ids = viewedYokaiIds
        ids.insert(documentId)
        viewedYokaiIds = ids
    }

    func registerExistingFavoriteIfNeeded(hasFavorites: Bool) {
        if hasFavorites {
            UserDefaults.standard.set(true, forKey: hasAddedFavoriteKey)
        }
    }

    /// 初めてお気に入りを追加した瞬間に一度だけ判定する。
    /// 異なる妖怪を3体以上閲覧済みなら、Apple標準レビューを要求してよい。
    func shouldRequestReviewAfterFirstFavorite() -> Bool {
        let defaults = UserDefaults.standard

        guard !defaults.bool(forKey: hasAddedFavoriteKey) else { return false }
        defaults.set(true, forKey: hasAddedFavoriteKey)

        guard viewedYokaiIds.count >= 3 else { return false }
        guard !defaults.bool(forKey: hasRequestedReviewKey) else { return false }

        defaults.set(true, forKey: hasRequestedReviewKey)
        return true
    }
}
