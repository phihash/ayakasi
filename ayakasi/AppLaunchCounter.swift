import Foundation

final class ReviewRequestManager {
    static let shared = ReviewRequestManager()

    // 旧版(初ブックマーク時に依頼)で出した人にもう一度出さないよう、キー名は旧版のまま
    private let hasRequestedReviewKey = "hasRequestedReview"
    private let activeDayCountKey = "reviewActiveDayCount"
    private let lastActiveDayKey = "reviewLastActiveDay"

    private init() {}

    // 起動した日でなく妖怪を開いた日を数えるのは、通知やURLから開いてすぐ閉じた日を「使った日」に入れないため
    func recordActiveDay() {
        let defaults = UserDefaults.standard
        // timeZone: .currentを付けないと.iso8601はUTCで日付を切り、日本では朝9時に日付が変わってしまう
        let today = Date().formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        guard defaults.string(forKey: lastActiveDayKey) != today else { return }
        defaults.set(today, forKey: lastActiveDayKey)
        defaults.set(defaults.integer(forKey: activeDayCountKey) + 1, forKey: activeDayCountKey)
    }

    /// 妖怪を開いた日が通算3日以上になったら、一度だけレビューを要求してよい
    func shouldRequestReviewForActiveDays() -> Bool {
        let defaults = UserDefaults.standard
        guard defaults.integer(forKey: activeDayCountKey) >= 3,
              !defaults.bool(forKey: hasRequestedReviewKey) else { return false }
        defaults.set(true, forKey: hasRequestedReviewKey)
        return true
    }
}
