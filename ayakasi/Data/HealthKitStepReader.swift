import Foundation
import HealthKit
import WidgetKit
import os

/// HealthKitから歩数を読み、GrowthStoreへ反映する。**アプリ専用の唯一の書き込み口**。
/// ウィジェットはここを一切呼ばない（読むだけ）。
enum HealthKitStepReader {
    private static let store = HKHealthStore()
    private static var observerStarted = false

    /// 歩数の読み取り許可を求める（アプリのフォアグラウンドからのみ。プロンプトを出す）
    static func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let stepType = HKQuantityType(.stepCount)
        try? await store.requestAuthorization(toShare: [], read: [stepType])
        // 許可フローを通過した記録（ウィジェットが誘導表示をやめて卵表示に切り替わる）
        GrowthStore.markSetupDone()
        // 許可後にバックグラウンド配信を有効化（未許可なら無害に失敗する）
        store.enableBackgroundDelivery(for: stepType, frequency: .hourly) { _, _ in }
    }

    /// 今日の歩数を取り込み、卵に反映し、ウィジェットを更新する。
    /// - Returns: この呼び出しで新たに孵化した記録（通知を出すのは呼び出し側）
    @discardableResult
    static func refresh() async -> [GrowthStore.HatchRecord] {
        guard let steps = await HealthKitSteps.today() else {
            Logger.data.error("歩数同期: HealthKit利用不可")
            return []
        }
        let result = GrowthStore.apply(todaySteps: steps)
        Logger.data.debug("歩数同期: HK読取=\(steps) → egg=\(result.snapshot.eggSteps) 今日表示=\(result.snapshot.todaySteps) 新規孵化=\(result.newHatches.count)")
        // どの経路（起動時・孵化リスト・バックグラウンド監視）から来ても孵化を取りこぼさず通知する
        if !result.newHatches.isEmpty {
            await NotificationScheduler.scheduleHatchNotifications(result.newHatches)
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "AyakasiWidget")
        return result.newHatches
    }

    /// 現在のHealthKit読み取り許可の状態（診断用。.sharingAuthorized=許可, .sharingDenied=拒否, .notDetermined=未決定）
    static func authorizationStatusDescription() -> String {
        guard HKHealthStore.isHealthDataAvailable() else { return "HealthKit利用不可" }
        switch store.authorizationStatus(for: HKQuantityType(.stepCount)) {
        case .sharingAuthorized: return "許可済み"
        case .sharingDenied: return "拒否"
        case .notDetermined: return "未決定"
        @unknown default: return "不明"
        }
    }

    /// 歩数変化でアプリをバックグラウンド起動してもらうための監視を開始する。
    /// AppDelegateから毎起動時に呼ぶ（プロセスごとに1回だけ登録される）。
    static func startObserving() {
        guard HKHealthStore.isHealthDataAvailable(), !observerStarted else { return }
        observerStarted = true
        let stepType = HKQuantityType(.stepCount)
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, completion, _ in
            Task {
                _ = await refresh() // refresh内で通知＆ウィジェット更新まで行う
                completion() // HealthKitに処理完了を伝える（必須）
            }
        }
        store.execute(query)
        store.enableBackgroundDelivery(for: stepType, frequency: .hourly) { _, _ in }
    }
}
