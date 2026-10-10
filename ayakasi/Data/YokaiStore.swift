import Foundation
import Combine

/// 妖怪データの供給元。原本はD1。アプリ内に同梱スナップショットは持たない。
/// 読み込み: App Groupキャッシュ（前回取得のリモート版）→ 起動時にrefreshでリモート(Worker)確認。
/// 初回起動でキャッシュが無く取得にも失敗したときは .failed を公開し、UIが再試行できるようにする。
final class YokaiStore: ObservableObject {
    static let shared = YokaiStore()

    enum Phase { case loading, ready, failed }

    @Published private(set) var yokai: [Ayakasi] = []
    @Published private(set) var destinations: [YokaiDestination] = []
    @Published private(set) var phase: Phase = .loading

    private static let remoteURL = URL(string: "https://yokai-images.insharp0220.workers.dev/data.json")!
    private static let appGroupID = "group.net.phihash.ayakasi"
    private static let etagKey = "yokaiDataEtag"

    private init() {
        if let payload = Self.loadCached() {
            yokai = payload.yokai
            destinations = payload.destinations ?? []
            phase = .ready
        }
        // キャッシュが無ければ .loading のまま。refresh()で確定する。
    }

    private static var cacheURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("data.json")
    }

    private static func decode(_ data: Data) -> YokaiData? {
        guard let payload = try? JSONDecoder().decode(YokaiData.self, from: data),
              !payload.yokai.isEmpty else { return nil }
        return payload
    }

    private static func loadCached() -> YokaiData? {
        guard let url = cacheURL, let data = try? Data(contentsOf: url) else { return nil }
        return decode(data)
    }

    /// リモートの更新を確認して取り込む。データが無い状態で失敗したら .failed にする。
    @MainActor
    func refresh() async {
        if yokai.isEmpty { phase = .loading }

        var request = URLRequest(url: Self.remoteURL)
        // データを持っているときだけ条件付きGET。無いときは必ず全取得して確実に埋める。
        if !yokai.isEmpty, let etag = UserDefaults.standard.string(forKey: Self.etagKey) {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse else {
            if yokai.isEmpty { phase = .failed }  // データがあるなら黙って現状維持
            return
        }

        if http.statusCode == 304 {
            phase = .ready
            return
        }
        guard http.statusCode == 200, let fresh = Self.decode(data) else {
            if yokai.isEmpty { phase = .failed }
            return
        }

        yokai = fresh.yokai
        destinations = fresh.destinations ?? destinations
        phase = .ready
        if let url = Self.cacheURL {
            try? data.write(to: url, options: .atomic)
        }
        if let etag = http.value(forHTTPHeaderField: "Etag") {
            UserDefaults.standard.set(etag, forKey: Self.etagKey)
        }
    }
}

/// 既存コード互換のグローバル。中身はYokaiStoreが供給する。
var ayakasis: [Ayakasi] { YokaiStore.shared.yokai }
var yokaiDestinations: [YokaiDestination] { YokaiStore.shared.destinations }
