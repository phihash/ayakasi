import Foundation

class AppLaunchCounter {
    static let shared = AppLaunchCounter()
    private let launchCountKey = "appLaunchCount"
    private let hasRequestedReviewKey = "hasRequestedReview"

    private init() {}

    // 起動回数を取得
    var launchCount: Int {
        UserDefaults.standard.integer(forKey: launchCountKey)
    }

    // レビューリクエスト済みかどうか
    var hasRequestedReview: Bool {
        UserDefaults.standard.bool(forKey: hasRequestedReviewKey)
    }

    // 起動回数をインクリメント
    func incrementLaunchCount() {
        let newCount = launchCount + 1
        UserDefaults.standard.set(newCount, forKey: launchCountKey)
    }

    // レビューリクエストが必要かチェック
    func shouldRequestReview() -> Bool {
        // すでにリクエスト済みなら不要
        guard !hasRequestedReview else { return false }

        // 3回目の起動時にレビューリクエスト
        return launchCount >= 3
    }

    // レビューリクエスト済みフラグを立てる
    func markReviewRequested() {
        UserDefaults.standard.set(true, forKey: hasRequestedReviewKey)
    }

    // アプリ起動時の処理（満足度アラートを表示すべきかを返す）
    func handleAppLaunch() -> Bool {
        // 起動回数をカウント
        incrementLaunchCount()

        // 3回目の起動時に満足度アラートを表示
        return shouldRequestReview()
    }
}
