import Foundation

/// 歩数で卵を孵化させる「妖怪ガチャ」の状態管理（純ロジック層。HealthKitには触らない）。
/// - 状態はApp Groupコンテナ内の1ファイルにアトミック保存し、アプリとウィジェットの両方から読む。
/// - **書き込むのは常にアプリ側だけ**（HealthKitStepReader経由）。ウィジェットは読むだけ。
///   これによりプロセス跨ぎの書き込み競合が構造的に起きない。
enum GrowthStore {

    /// 卵1個の孵化に必要な歩数
    static let hatchSteps = 10_000

    /// ガチャで生まれる妖怪（ちびキャラ画像があるものだけ）。
    /// 画像を追加したらここにdocumentIdを足し、R2に `chibi-<documentId>.png` を置く。
    static let hatchPool: [String] = ["kappa", "oni", "yukionna", "tengu"]

    /// ちびキャラ画像のURL（R2/Worker配信）
    static func chibiImageURL(for documentId: String) -> URL? {
        URL(string: "https://yokai-images.insharp0220.workers.dev/chibi-\(documentId).png")
    }

    // MARK: - モデル

    struct HatchRecord: Codable, Identifiable {
        let documentId: String
        let date: Date
        var id: String { "\(documentId)-\(date.timeIntervalSince1970)" }
    }

    /// 永続化する状態（1ファイル＝1スナップショット。読み手はこれ全体を一貫して受け取る）
    private struct State: Codable {
        var eggSteps = 0
        var countedSteps = 0
        var countedDay = ""
        var todaySteps = 0
        var hatched: [HatchRecord] = []
        /// 歩数の許可フローを一度でも通過したか。旧ファイル互換のためOptional（nil=未設定=false扱い）
        var setupDone: Bool? = nil
    }

    struct Snapshot {
        let todaySteps: Int
        let eggSteps: Int
        let hatchedCount: Int
        /// 今日孵化したばかりの妖怪（いれば。ウィジェットでお披露目する）
        let hatchedToday: HatchRecord?
        /// 許可フローを通過済みか。falseならウィジェットは「未セットアップ誘導」を出す
        let setupDone: Bool

        var progress: Double { min(1, Double(eggSteps) / Double(GrowthStore.hatchSteps)) }
        var stepsToHatch: Int { max(0, GrowthStore.hatchSteps - eggSteps) }
    }

    // MARK: - 保存（App Groupコンテナ内の単一ファイル）

    private static let appGroupID = "group.net.phihash.ayakasi"
    /// アプリ内で foreground と background の apply() が重ならないよう直列化する
    private static let lock = NSLock()

    private static var stateURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("growth-state.json")
    }

    private static func loadState() -> State {
        guard let url = stateURL, let data = try? Data(contentsOf: url),
              let state = try? JSONDecoder().decode(State.self, from: data) else {
            return State()
        }
        return state
    }

    private static func saveState(_ state: State) {
        guard let url = stateURL, let data = try? JSONEncoder().encode(state) else { return }
        // アトミック書き込み（一時ファイル→リネーム）＝読み手はちぎれた状態を絶対に見ない
        try? data.write(to: url, options: .atomic)
    }

    private static func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    private static func latestHatchToday(_ records: [HatchRecord]) -> HatchRecord? {
        guard let last = records.last, dayKey(last.date) == dayKey(Date()) else { return nil }
        return last
    }

    private static func snapshot(from state: State) -> Snapshot {
        let isToday = state.countedDay == dayKey(Date())
        return Snapshot(
            todaySteps: isToday ? state.todaySteps : 0,
            eggSteps: state.eggSteps,
            hatchedCount: state.hatched.count,
            hatchedToday: latestHatchToday(state.hatched),
            setupDone: state.setupDone ?? false
        )
    }

    // MARK: - 読み取り（ウィジェット・アプリ共通。副作用なし）

    static func cachedSnapshot() -> Snapshot {
        snapshot(from: loadState())
    }

    /// ウィジェット表示用の暫定スナップショット。live歩数で見た目だけ先に進める。
    /// **保存も孵化もしない**（実際の孵化・記録はアプリのapply()だけが行う）。
    /// これによりウィジェットは書き込みをせず、歩数表示だけライブに追従できる。
    static func provisionalSnapshot(liveSteps: Int) -> Snapshot {
        let state = loadState()
        let isToday = state.countedDay == dayKey(Date())
        // アプリが最後にカウントした地点からの増分だけ見た目に足す
        let base = isToday ? state.countedSteps : 0
        let extra = max(0, liveSteps - base)
        // 孵化ラインで頭打ち（実際の孵化はアプリが動いたとき）
        let provisionalEgg = min(hatchSteps, state.eggSteps + extra)
        return Snapshot(
            todaySteps: isToday ? max(state.todaySteps, liveSteps) : liveSteps,
            eggSteps: provisionalEgg,
            hatchedCount: state.hatched.count,
            hatchedToday: latestHatchToday(state.hatched),
            setupDone: state.setupDone ?? false
        )
    }

    static func hatchedRecords() -> [HatchRecord] {
        loadState().hatched
    }

    /// 許可フローを通過したことを記録する（ウィジェットが「未セットアップ誘導」を出すか判定するのに使う）
    static func markSetupDone() {
        lock.lock()
        defer { lock.unlock() }
        var state = loadState()
        guard state.setupDone != true else { return }
        state.setupDone = true
        saveState(state)
    }

    // MARK: - 書き込み（アプリ側だけが呼ぶ。HealthKitStepReader経由）

    /// 今日の歩数を反映して卵を進め、孵化条件を満たしたら孵化させる。
    /// - Returns: 更新後スナップショットと、この呼び出しで新たに孵化した記録
    @discardableResult
    static func apply(todaySteps: Int) -> (snapshot: Snapshot, newHatches: [HatchRecord]) {
        lock.lock()
        defer { lock.unlock() }

        var state = loadState()
        let today = dayKey(Date())

        // 日付が変わったら「今日ぶんカウント済み」だけリセット（卵の進捗は翌日へ繰り越す）
        if state.countedDay != today {
            state.countedDay = today
            state.countedSteps = 0
        }

        // 歩数は同じ日のうちは減らない。低い読み取り値（ロック中の失敗値など）が来ても
        // 巻き戻さない＝次の正常値での二重加算を防ぐ。
        let effectiveToday = max(state.countedSteps, todaySteps)
        let delta = effectiveToday - state.countedSteps
        state.countedSteps = effectiveToday
        state.todaySteps = effectiveToday
        state.eggSteps += delta

        var newHatches: [HatchRecord] = []
        while state.eggSteps >= hatchSteps {
            guard let born = pickRandomYokai(excluding: state.hatched.map(\.documentId)) else { break }
            state.eggSteps -= hatchSteps
            let record = HatchRecord(documentId: born.documentId, date: Date())
            state.hatched.append(record)
            newHatches.append(record)
        }

        saveState(state)
        return (snapshot(from: state), newHatches)
    }

    /// ガチャプール内の未孵化の妖怪からランダムに1体選ぶ。プールをコンプしたらプール全体から選ぶ。
    private static func pickRandomYokai(excluding hatchedIds: [String]) -> Ayakasi? {
        let pool = ayakasis.filter { hatchPool.contains($0.documentId) }
        guard !pool.isEmpty else { return nil }
        let remaining = pool.filter { !hatchedIds.contains($0.documentId) }
        return (remaining.isEmpty ? pool : remaining).randomElement()
    }
}
