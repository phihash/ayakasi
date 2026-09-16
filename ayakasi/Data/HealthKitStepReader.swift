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
        // 許可フローを通過した記録（ウィジェットが誘導表示をやめて卵表示に切り替わる）。
        // 初回はここで許可時刻が記録され、それ以降の歩数だけが育成に使われる。
        GrowthStore.markSetupDone()
        // 拒否は直接検知できない（Appleの仕様で「データ0件」と区別がつかない）ので、
        // 過去7日の歩数が読めるかで推定する。0なら「許可を確認して」誘導につながる。
        let readable = await HealthKitSteps.hasSteps(inLastDays: 7)
        GrowthStore.setHealthReadOK(readable)
        // 許可後にバックグラウンド配信を有効化（未許可なら無害に失敗する）
        store.enableBackgroundDelivery(for: stepType, frequency: .hourly) { _, _ in }
    }

    /// 歩数を取り込み、卵に反映し、ウィジェットを更新する。
    /// 1) アプリを開かなかった過去日を補填 → 2) 今日ぶんを反映（歩いたぶんは必ず育つ）。
    /// - Returns: この呼び出しで新たに孵化した記録（通知を出すのは呼び出し側）
    @discardableResult
    static func refresh() async -> [GrowthStore.HatchRecord] {
        let context = GrowthStore.syncContext()
        var newHatches: [GrowthStore.HatchRecord] = []
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        // 1) 未反映の過去日（最後にカウントした日〜昨日）を補填。許可時刻より前は数えない。
        //    未カウントの新規ユーザーは許可日から。読めなかったら黙ってスキップ（次回に補填される）。
        let backfillStart = context.countedDate ?? context.setupDate.map { calendar.startOfDay(for: $0) }
        if let start = backfillStart, start < todayStart,
           let totals = await HealthKitSteps.dailyTotals(from: start, to: todayStart, notBefore: context.setupDate) {
            let result = GrowthStore.applyPastDays(totals)
            newHatches.append(contentsOf: result.newHatches)
            if !totals.isEmpty {
                Logger.data.debug("歩数補填: \(totals.count)日ぶん → egg=\(result.snapshot.eggSteps) 補填孵化=\(result.newHatches.count)")
            }
        }

        // 2) 今日ぶんを反映（読み取り基準時刻ごと渡し、0時マタギの二重加算を防ぐ）
        if let reading = await HealthKitSteps.today(notBefore: context.setupDate) {
            let result = GrowthStore.apply(todaySteps: reading.steps, asOf: reading.asOf)
            Logger.data.debug("歩数同期: HK読取=\(reading.steps) → egg=\(result.snapshot.eggSteps) 今日表示=\(result.snapshot.todaySteps) 新規孵化=\(result.newHatches.count)")
            newHatches.append(contentsOf: result.newHatches)
            // 歩数が実際に読めた＝許可されている（設定で後から許可し直した場合の自動復帰）
            if reading.steps > 0 { GrowthStore.setHealthReadOK(true) }
        } else {
            Logger.data.error("歩数同期: 読み取り失敗（利用不可・ロック中など）。反映せず次回に持ち越し")
        }

        // どの経路（起動時・孵化リスト・バックグラウンド監視）から来ても孵化を取りこぼさず通知する
        // TODO: 歩数計まわりの仕様を詰めるまで「うまれた！」通知は一旦停止（孵化の計算・記録は継続＝孵化リストには反映される）。
        // if !newHatches.isEmpty {
        //     await NotificationScheduler.scheduleHatchNotifications(newHatches)
        // }
        WidgetCenter.shared.reloadTimelines(ofKind: "AyakasiWidget")
        return newHatches
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
