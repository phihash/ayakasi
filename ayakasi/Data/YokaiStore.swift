import Foundation
import Combine

/// 妖怪データの供給元。
/// 読み込み順: App Groupキャッシュ（リモート取得済み） → バンドル同梱のdata.json。
/// refresh()がETag付きでリモート(R2/Worker)を確認し、更新があれば差し替えて保存する。
final class YokaiStore: ObservableObject {
    static let shared = YokaiStore()

    @Published private(set) var yokai: [Ayakasi] = []

    private static let remoteURL = URL(string: "https://yokai-images.insharp0220.workers.dev/data.json")!
    private static let appGroupID = "group.net.phihash.ayakasi"
    private static let etagKey = "yokaiDataEtag"

    private init() {
        yokai = Self.loadCached() ?? Self.loadBundled() ?? []
    }

    private static var cacheURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("data.json")
    }

    private static func decode(_ data: Data) -> [Ayakasi]? {
        guard let payload = try? JSONDecoder().decode(YokaiData.self, from: data),
              !payload.yokai.isEmpty else { return nil }
        return payload.yokai
    }

    private static func loadCached() -> [Ayakasi]? {
        guard let url = cacheURL, let data = try? Data(contentsOf: url) else { return nil }
        return decode(data)
    }

    private static func loadBundled() -> [Ayakasi]? {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return decode(data)
    }

    /// リモートの更新を確認して取り込む。ETagが一致すれば304が返り、何もしない。
    @MainActor
    func refresh() async {
        var request = URLRequest(url: Self.remoteURL)
        if let etag = UserDefaults.standard.string(forKey: Self.etagKey) {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse,
              http.statusCode == 200,
              let fresh = Self.decode(data) else { return }
        yokai = fresh
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
