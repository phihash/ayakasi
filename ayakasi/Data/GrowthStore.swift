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
        /// 許可フローを通過した時刻。**この時刻より前の歩数は育成に使わない**（入れた瞬間の即孵化防止）。
        /// 旧ユーザーはnil＝制限なし（従来どおり0時起点でカウント）
        var setupDate: Date? = nil
        /// 歩数が実際に読めているか（過去7日クエリでの推定）。nil=未確認（旧ユーザー含む・警告は出さない）
        var healthReadOK: Bool? = nil
    }

    struct Snapshot {
        let todaySteps: Int
        let eggSteps: Int
        let hatchedCount: Int
        /// 今日孵化したばかりの妖怪（いれば。ウィジェットでお披露目する）
        let hatchedToday: HatchRecord?
        /// 許可フローを通過済みか。falseならウィジェットは「未セットアップ誘導」を出す
        let setupDone: Bool
        /// 歩数が読めているか（推定）。falseならウィジェットは「許可を確認して」誘導を出す
        let healthReadOK: Bool

        var progress: Double { min(1, Double(eggSteps) / Double(GrowthStore.hatchSteps)) }
        var stepsToHatch: Int { max(0, GrowthStore.hatchSteps - eggSteps) }

        /// 翌日0時のウィジェット表示用（歩数0・お披露目終了。卵の進捗は引き継ぐ）
        func resettingForNewDay() -> Snapshot {
            Snapshot(todaySteps: 0, eggSteps: eggSteps, hatchedCount: hatchedCount,
                     hatchedToday: nil, setupDone: setupDone, healthReadOK: healthReadOK)
        }
    }

    /// 歩数同期に必要な文脈（読み取り専用）
    struct SyncContext {
        /// 最後に歩数をカウントした日（その日の0時）。未カウントならnil
        let countedDate: Date?
        /// 許可フロー通過時刻。これより前の歩数は数えない。旧ユーザーはnil
        let setupDate: Date?
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

    private static func date(fromDayKey key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3, parts[0] > 0 else { return nil }
        return Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
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
            setupDone: state.setupDone ?? false,
            healthReadOK: state.healthReadOK ?? true
        )
    }

    // MARK: - 読み取り（ウィジェット・アプリ共通。副作用なし）

    static func cachedSnapshot() -> Snapshot {
        snapshot(from: loadState())
    }

    /// ウィジェット表示用の暫定スナップショット。live歩数で見た目だけ先に進める。
    /// **保存も孵化もしない**（実際の孵化・記録はアプリのapply()だけが行う）。
    /// asOf = 歩数を読んだ基準時刻。日付判定を読み取り時点に揃える。
    static func provisionalSnapshot(liveSteps: Int, asOf: Date) -> Snapshot {
        let state = loadState()
        let sameDay = state.countedDay == dayKey(asOf)
        // アプリが最後にカウントした地点からの増分だけ見た目に足す
        let base = sameDay ? state.countedSteps : 0
        let extra = max(0, liveSteps - base)
        // 孵化ラインで頭打ち（実際の孵化はアプリが動いたとき）
        let provisionalEgg = min(hatchSteps, state.eggSteps + extra)
        return Snapshot(
            todaySteps: sameDay ? max(state.todaySteps, liveSteps) : liveSteps,
            eggSteps: provisionalEgg,
            hatchedCount: state.hatched.count,
            hatchedToday: latestHatchToday(state.hatched),
            setupDone: state.setupDone ?? false,
            healthReadOK: state.healthReadOK ?? true
        )
    }

    static func hatchedRecords() -> [HatchRecord] {
        loadState().hatched
    }

    /// 歩数同期に必要な文脈を返す（HealthKitStepReaderとウィジェットが使う）
    static func syncContext() -> SyncContext {
        let state = loadState()
        return SyncContext(countedDate: date(fromDayKey: state.countedDay),
                           setupDate: state.setupDate)
    }

    /// 許可フローを通過したことを記録する（ウィジェットが「未セットアップ誘導」を出すか判定するのに使う）。
    /// 初回通過時のみ通過時刻も記録し、**その時刻以降の歩数だけ**を育成に使う。
    static func markSetupDone() {
        lock.lock()
        defer { lock.unlock() }
        var state = loadState()
        guard state.setupDone != true else { return }
        state.setupDone = true
        state.setupDate = Date()
        saveState(state)
    }

    /// 歩数が読めているか（過去7日クエリの推定結果）を記録する
    static func setHealthReadOK(_ ok: Bool) {
        lock.lock()
        defer { lock.unlock() }
        var state = loadState()
        guard state.healthReadOK != ok else { return }
        state.healthReadOK = ok
        saveState(state)
    }

    // MARK: - 書き込み（アプリ側だけが呼ぶ。HealthKitStepReader経由）

    /// 今日の歩数を反映して卵を進め、孵化条件を満たしたら孵化させる。
    /// - Parameter asOf: 歩数を読んだ基準時刻。**読み取りと同じ時刻で日付判定する**ことで、
    ///   0時マタギ（23:59に読んで0:00に反映）でも昨日の歩数が二重加算されない。
    /// - Returns: 更新後スナップショットと、この呼び出しで新たに孵化した記録
    @discardableResult
    static func apply(todaySteps: Int, asOf: Date) -> (snapshot: Snapshot, newHatches: [HatchRecord]) {
        lock.lock()
        defer { lock.unlock() }

        var state = loadState()
        let readDay = dayKey(asOf)

        if state.countedDay == readDay {
            // 同じ日のうちの更新（0時マタギの遅延反映も、まだその日をカウント中なら安全に取り込める）
        } else if readDay == dayKey(Date()) {
            // 新しい日が始まった。「今日ぶんカウント済み」だけリセット（卵の進捗は翌日へ繰り越す）
            state.countedDay = readDay
            state.countedSteps = 0
        } else {
            // 既に過ぎた日の読み取りが遅れて届いた → 破棄（過去日はapplyPastDaysの補填が担当）
            return (snapshot(from: state), [])
        }

        // 歩数は同じ日のうちは減らない。低い読み取り値（ロック中の失敗値など）が来ても
        // 巻き戻さない＝次の正常値での二重加算を防ぐ。
        let effectiveToday = max(state.countedSteps, todaySteps)
        let delta = effectiveToday - state.countedSteps
        state.countedSteps = effectiveToday
        state.todaySteps = effectiveToday
        state.eggSteps += delta

        let newHatches = hatchIfNeeded(&state)
        saveState(state)
        return (snapshot(from: state), newHatches)
    }

    /// アプリを開かなかった過去日の歩数を補填する（古い日から順に処理）。
    /// - 最後にカウントした日と同じ日 → カウント済みとの差分だけ加算（二重加算しない）
    /// - それより後の日 → 全量を加算してカウント済み日を進める
    /// - それより前の日・今日 → 無視（過去は反映済み、今日はapply()の担当）
    @discardableResult
    static func applyPastDays(_ days: [(date: Date, steps: Int)]) -> (snapshot: Snapshot, newHatches: [HatchRecord]) {
        lock.lock()
        defer { lock.unlock() }

        var state = loadState()
        let today = dayKey(Date())
        var newHatches: [HatchRecord] = []

        for entry in days.sorted(by: { $0.date < $1.date }) {
            let day = dayKey(entry.date)
            guard day != today else { continue }
            if day == state.countedDay {
                let effective = max(state.countedSteps, entry.steps)
                state.eggSteps += effective - state.countedSteps
                state.countedSteps = effective
                state.todaySteps = effective
            } else if let counted = date(fromDayKey: state.countedDay), entry.date <= counted {
                continue // カウント済みより前の日＝反映済み
            } else {
                state.eggSteps += entry.steps
                state.countedDay = day
                state.countedSteps = entry.steps
                state.todaySteps = entry.steps
            }
            newHatches.append(contentsOf: hatchIfNeeded(&state))
        }

        saveState(state)
        return (snapshot(from: state), newHatches)
    }

    /// 孵化条件を満たしている間、孵化させ続ける（2万歩なら2体生まれる）
    private static func hatchIfNeeded(_ state: inout State) -> [HatchRecord] {
        var newHatches: [HatchRecord] = []
        while state.eggSteps >= hatchSteps {
            guard let born = pickRandomYokai(excluding: state.hatched.map(\.documentId)) else { break }
            state.eggSteps -= hatchSteps
            let record = HatchRecord(documentId: born.documentId, date: Date())
            state.hatched.append(record)
            newHatches.append(record)
        }
        return newHatches
    }

    /// ガチャプール内の未孵化の妖怪からランダムに1体選ぶ。プールをコンプしたらプール全体から選ぶ。
    private static func pickRandomYokai(excluding hatchedIds: [String]) -> Ayakasi? {
        let pool = ayakasis.filter { hatchPool.contains($0.documentId) }
        guard !pool.isEmpty else { return nil }
        let remaining = pool.filter { !hatchedIds.contains($0.documentId) }
        return (remaining.isEmpty ? pool : remaining).randomElement()
    }
}
