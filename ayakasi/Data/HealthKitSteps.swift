import Foundation
import HealthKit

/// HealthKitから今日の歩数を読むだけの共有ヘルパー（**読み取り専用**。書き込み・許可要求はしない）。
/// アプリとウィジェットの両方から使う。
enum HealthKitSteps {
    private static let store = HKHealthStore()

    /// 今日（0時〜現在）の累計歩数。HealthKitが使えない場合のみ nil。
    /// 歩数が無い/未許可のときは 0 を返す（呼び出し側で単調ガードがかかる）。
    static func today() async -> Int? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let stepType = HKQuantityType(.stepCount)
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, statistics, _ in
                let sum = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(sum))
            }
            store.execute(query)
        }
    }
}
