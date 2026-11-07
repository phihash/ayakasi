import Foundation

final class ReviewRequestManager {
    static let shared = ReviewRequestManager()

    private let viewCountKey = "reviewYokaiViewCount"
    private let lastRequestedDayKey = "reviewLastRequestedDay"

    private init() {}

    // 日数でなく開いた数を数えるのは、大半の人が1日しか来ないがその日にたくさん見ているため(Amplitude 2026-11: 翌日に戻る人9%、11体以上開く人3割)
    func recordYokaiViewed() {
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: viewCountKey) + 1, forKey: viewCountKey)
    }

    /// 妖怪を通算11体以上開いていれば、1日1回までレビューを要求してよい
    // 年3回の上限はOS側が掛けるので、こちらでは回数を数えず同じ日に何度も呼ばないことだけ守る
    func shouldRequestReview() -> Bool {
        let defaults = UserDefaults.standard
        // timeZone: .currentを付けないと.iso8601はUTCで日付を切り、日本では朝9時に日付が変わってしまう
        let today = Date().formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        guard defaults.integer(forKey: viewCountKey) >= 11,
              defaults.string(forKey: lastRequestedDayKey) != today else { return false }
        defaults.set(today, forKey: lastRequestedDayKey)
        return true
    }
}
