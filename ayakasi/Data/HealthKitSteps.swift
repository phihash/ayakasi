import Foundation
import HealthKit

/// HealthKitから歩数を読むだけの共有ヘルパー（**読み取り専用**。書き込み・許可要求はしない）。
/// アプリとウィジェットの両方から使う。
enum HealthKitSteps {
    private static let store = HKHealthStore()

    /// 今日の歩数の読み取り結果。asOf = 読み取り基準時刻（この時刻の属する日の歩数）。
    /// 反映側はこのasOfで日付判定することで、0時マタギの遅延反映でも二重加算しない。
    struct Reading {
        let steps: Int
        let asOf: Date
    }

    /// 今日（0時〜現在。notBeforeがあればその時刻〜現在）の累計歩数。
    /// **読めなかったとき（HealthKit利用不可・ロック中・権限エラー）は nil**。データ0件は0歩として返す。
    static func today(notBefore: Date? = nil) async -> Reading? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let now = Date()
        var start = Calendar.current.startOfDay(for: now)
        if let notBefore, notBefore > start { start = notBefore }
        guard start <= now, let steps = await sumSteps(from: start, to: now) else { return nil }
        return Reading(steps: steps, asOf: now)
    }

    /// 過去days日間に歩数データが1件でも読めるか。
    /// 読み取り許可の拒否は直接検知できない（Appleの仕様で「データ0件」と区別がつかない）ため、
    /// 「1週間持ち歩いて0歩はほぼあり得ない」ことを利用した推定に使う。
    static func hasSteps(inLastDays days: Int) async -> Bool {
        let now = Date()
        guard let start = Calendar.current.date(byAdding: .day, value: -days, to: now) else { return false }
        return (await sumSteps(from: start, to: now) ?? 0) > 0
    }

    /// 日別の歩数合計（fromの属する日から、toの前まで）。読めなかったら nil。
    /// notBeforeより前の歩数は数えない（許可時点より前を育成に使わないため）。
    /// アプリを開かなかった日の補填（バックフィル）に使う。
    static func dailyTotals(from: Date, to: Date, notBefore: Date? = nil) async -> [(date: Date, steps: Int)]? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let calendar = Calendar.current
        let anchor = calendar.startOfDay(for: from)
        var predicateStart = anchor
        if let notBefore, notBefore > predicateStart { predicateStart = notBefore }
        guard predicateStart < to else { return [] }
        let predicate = HKQuery.predicateForSamples(withStart: predicateStart, end: to)
        let stepType = HKQuantityType(.stepCount)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                    quantitySamplePredicate: predicate,
                                                    options: .cumulativeSum,
                                                    anchorDate: anchor,
                                                    intervalComponents: DateComponents(day: 1))
            query.initialResultsHandler = { _, collection, error in
                guard let collection else {
                    // データ0件は「全日0歩」、それ以外のエラーは「読めなかった」
                    if (error as? HKError)?.code == .errorNoData {
                        continuation.resume(returning: [])
                    } else {
                        continuation.resume(returning: nil)
                    }
                    return
                }
                var results: [(date: Date, steps: Int)] = []
                collection.enumerateStatistics(from: anchor, to: to) { stats, _ in
                    let steps = Int(stats.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    results.append((date: stats.startDate, steps: steps))
                }
                continuation.resume(returning: results)
            }
            store.execute(query)
        }
    }

    /// 期間内の歩数合計。読めなかったら nil、データ0件は 0。
    private static func sumSteps(from start: Date, to end: Date) async -> Int? {
        let stepType = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, statistics, error in
                if let sum = statistics?.sumQuantity() {
                    continuation.resume(returning: Int(sum.doubleValue(for: .count())))
                } else if (error as? HKError)?.code == .errorNoData || error == nil {
                    // データが1件も無いだけ＝正常な0歩
                    continuation.resume(returning: 0)
                } else {
                    // ロック中（データ保護）・権限エラーなど＝「0歩」と混同してはいけない
                    continuation.resume(returning: nil)
                }
            }
            store.execute(query)
        }
    }
}
