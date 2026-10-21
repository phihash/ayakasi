#if DEBUG
import SwiftUI
import ImageIO
import UIKit

// 妖怪画像を PNG と AVIF で取得し、ダウンロードとデコードの時間を分けて測る(記事用の計測)。
// 回線は 設定 > デベロッパ > Network Link Conditioner でそろえて測る。DEBUG ビルドにだけ入る。
struct ImageBenchmarkView: View {
    // 2026-10-17 に全画像を AVIF(品質60・原寸)へ移した。原画の PNG も R2 に残してあるので両方を比べられる
    private static let names = ["1kUq6RO", "2183Drq", "4ItCkkf", "4Nlpvq7", "6f5AJml", "7n5mGqa", "aI8w9Us",
                                "bJFGxYm", "Bq5cPyz", "dYXMVfh", "icV8xje", "iv40FyL", "J1E9oTL", "ndOToOO",
                                "P58gOj9", "Q5Y4U7J", "r9ld7sZ", "RTgmW0z", "XNQ5ovy", "Z3P2J1E"]
    private static let base = "https://yokai-images.insharp0220.workers.dev/"

    struct Sample { let bytes: Int; let downloadMs: Double; let decodeMs: Double }

    @State private var png: [Sample] = []
    @State private var avif: [Sample] = []
    @State private var progress = ""
    @State private var isRunning = false
    @State private var networkNote = "LTE"

    var body: some View {
        List {
            Section {
                TextField("回線のメモ(例: LTE, Wi-Fi)", text: $networkNote)
                Button(isRunning ? "計測中… \(progress)" : "計測する(20枚 × PNG/AVIF)") {
                    Task { await run() }
                }
                .disabled(isRunning)
            } footer: {
                Text("キャッシュを使わずに毎回ダウンロードします。回線は Network Link Conditioner でそろえてください。")
            }

            if !png.isEmpty, !avif.isEmpty {
                Section("結果(中央値)") {
                    row("PNG", png)
                    row("AVIF", avif)
                }
                Section {
                    Button("結果をコピー") { UIPasteboard.general.string = report }
                    Text(report).font(.caption.monospaced()).textSelection(.enabled)
                }
            }
        }
        .navigationTitle("画像の計測")
    }

    private func row(_ label: String, _ s: [Sample]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.headline)
            Text("1枚 \(kb(median(s.map { Double($0.bytes) })))KB ・ DL \(ms(median(s.map(\.downloadMs))))ms ・ デコード \(ms(median(s.map(\.decodeMs))))ms ・ 合計 \(ms(median(s.map { $0.downloadMs + $0.decodeMs })))ms")
                .font(.subheadline)
        }
    }

    private var report: String {
        func line(_ label: String, _ s: [Sample]) -> String {
            let dl = s.map(\.downloadMs), dec = s.map(\.decodeMs), total = s.map { $0.downloadMs + $0.decodeMs }
            return "\(label): 合計\(kb(Double(s.map(\.bytes).reduce(0, +))))KB / 1枚中央\(kb(median(s.map { Double($0.bytes) })))KB"
                + " | DL 中央\(ms(median(dl)))ms 最大\(ms(dl.max() ?? 0))ms"
                + " | デコード 中央\(ms(median(dec)))ms 最大\(ms(dec.max() ?? 0))ms"
                + " | 合計 中央\(ms(median(total)))ms"
        }
        return """
        端末: \(Self.deviceModel) / iOS \(UIDevice.current.systemVersion) / 回線: \(networkNote) / \(png.count)枚
        \(line("PNG ", png))
        \(line("AVIF", avif))
        """
    }

    private func run() async {
        isRunning = true
        defer { isRunning = false; progress = "" }
        png = []; avif = []
        // キャッシュを使わない専用セッション。毎回ネットワークから取る
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        // 最初の1回は接続の確立(DNS・TLS)を含んで遅いので、計測から外す
        _ = try? await session.data(from: URL(string: Self.base + "events")!)

        var p: [Sample] = [], a: [Sample] = []
        for (i, name) in Self.names.enumerated() {
            progress = "\(i + 1)/\(Self.names.count)"
            // 同じ画像を続けて取り、時間帯や回線の揺れが片方の形式にだけ偏らないようにする
            if let s = await measure(session, Self.base + name + ".png") { p.append(s) }
            if let s = await measure(session, Self.base + name + ".avif") { a.append(s) }
        }
        png = p; avif = a
        print("[ImageBenchmark]\n" + report)
    }

    private func measure(_ session: URLSession, _ urlString: String) async -> Sample? {
        guard let url = URL(string: urlString) else { return nil }
        let start = DispatchTime.now()
        guard let (data, _) = try? await session.data(from: url) else { return nil }
        let downloadMs = elapsedMs(since: start)

        // 画面に出せる状態(ピクセルの並び)まで展開させて、その時間を測る
        let decodeStart = DispatchTime.now()
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary)
        else { return nil }
        _ = image.dataProvider?.data
        return Sample(bytes: data.count, downloadMs: downloadMs, decodeMs: elapsedMs(since: decodeStart))
    }

    private func elapsedMs(since start: DispatchTime) -> Double {
        Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
    }
    private func median(_ v: [Double]) -> Double {
        let s = v.sorted()
        return s.isEmpty ? 0 : (s.count % 2 == 1 ? s[s.count / 2] : (s[s.count / 2 - 1] + s[s.count / 2]) / 2)
    }
    private func ms(_ v: Double) -> String { String(Int(v.rounded())) }
    private func kb(_ v: Double) -> String { String(Int((v / 1024).rounded())) }

    // "iPhone15,2" のような機種ID(記事に機種名を書くときの対応表はAppleのサイトで引く)
    private static var deviceModel: String {
        var info = utsname()
        uname(&info)
        return withUnsafeBytes(of: &info.machine) { String(decoding: $0.prefix { $0 != 0 }, as: UTF8.self) }
    }
}
#endif
