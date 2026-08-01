import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GrowthEntry {
        GrowthEntry(date: Date(), snapshot: GrowthStore.cachedSnapshot(),
                    hatchedName: nil, hatchedDocumentId: nil, hatchedImageData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (GrowthEntry) -> ()) {
        completion(GrowthEntry(date: Date(), snapshot: GrowthStore.cachedSnapshot(),
                               hatchedName: nil, hatchedDocumentId: nil, hatchedImageData: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GrowthEntry>) -> ()) {
        Task {
            // 表示用に今日の歩数をHealthKitから読む（読み取りのみ・状態は書き換えない）。
            // 取れない（ロック中・未許可）ときは保存済みキャッシュを使う。孵化・記録はアプリだけが行う。
            let snapshot: GrowthStore.Snapshot
            if let live = await HealthKitSteps.today() {
                snapshot = GrowthStore.provisionalSnapshot(liveSteps: live)
            } else {
                snapshot = GrowthStore.cachedSnapshot()
            }

            // 今日孵化していたら、その妖怪の名前と画像を用意してお披露目する。
            // 画像は「同梱チビ画像」を最優先（確実・即時）。無い妖怪だけ図鑑画像をネット取得。
            var hatchedName: String? = nil
            var hatchedDocumentId: String? = nil
            var imageData: Data? = nil
            if let hatched = snapshot.hatchedToday,
               let yokai = ayakasis.first(where: { $0.documentId == hatched.documentId }) {
                hatchedName = yokai.name
                hatchedDocumentId = yokai.documentId
                // 同梱チビ画像が無い妖怪のときだけ、図鑑画像をネット取得（フォールバック）
                if UIImage(named: "chibi-\(yokai.documentId)") == nil,
                   let url = URL(string: yokai.imageName),
                   let (data, response) = try? await URLSession.shared.data(from: url),
                   (response as? HTTPURLResponse)?.statusCode == 200, !data.isEmpty {
                    imageData = data
                }
            }

            let entry = GrowthEntry(date: Date(), snapshot: snapshot,
                                    hatchedName: hatchedName,
                                    hatchedDocumentId: hatchedDocumentId,
                                    hatchedImageData: imageData)
            // 30分ごとに歩数を読み直す（iOSの予算内。アプリ更新時はreloadTimelinesで即反映）
            let refreshAt = Date().addingTimeInterval(30 * 60)
            completion(Timeline(entries: [entry], policy: .after(refreshAt)))
        }
    }
}

struct GrowthEntry: TimelineEntry {
    let date: Date
    let snapshot: GrowthStore.Snapshot
    let hatchedName: String?
    let hatchedDocumentId: String?
    let hatchedImageData: Data?
}

struct AyakasiWidgetEntryView : View {
    var entry: GrowthEntry
    @Environment(\.widgetFamily) var family

    private var snap: GrowthStore.Snapshot { entry.snapshot }
    private var isRevealDay: Bool { entry.hatchedName != nil }

    var body: some View {
        Group {
            if !snap.setupDone {
                // 許可フロー未通過 → 誘導表示（0歩や空バーは出さない）
                if family == .systemMedium { notSetUpMedium } else { notSetUpSmall }
            } else if family == .systemMedium {
                medium
            } else {
                small
            }
        }
        // 未セットアップのときはタップで許可フローへ（アプリが ayakasi://start を消化）
        .widgetURL(snap.setupDone ? nil : URL(string: "ayakasi://start"))
    }


    private var notSetUpMedium: some View {
        HStack(spacing: 14) {
            Text("🥚")
                .font(.system(size: 74))
                .frame(width: 92, height: 92)
            VStack(alignment: .leading, spacing: 6) {
                Text("妖怪のたまご")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("歩いて妖怪を育てよう")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                Text("タップしてはじめる")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(accentGreen)
            }
            Spacer(minLength: 0)
        }
    }

    private var notSetUpSmall: some View {
        VStack(spacing: 6) {
            Text("🥚")
                .font(.system(size: 58))
            Text("歩いて育てる")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
            Text("タップで開始")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(accentGreen)
        }
    }


    private var small: some View {
        VStack(spacing: 4) {
            centerImage(size: 74)
            Text(isRevealDay ? "\(entry.hatchedName!)がうまれた！" : "なにかのたまご")
                .font(isRevealDay ? .caption : .subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            statsRow
            Spacer()
            progressBar
        }
    }


    private var medium: some View {
        HStack(spacing: 14) {
            centerImage(size: 92)
            VStack(alignment: .leading, spacing: 6) {
                Text(isRevealDay ? "🎉 \(entry.hatchedName!)がうまれた！" : "なにかのたまご")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                statsRow
                progressBar
                
            }
        }
    }


    private func centerImage(size: CGFloat) -> some View {
        Group {
            if let id = entry.hatchedDocumentId, UIImage(named: "chibi-\(id)") != nil {
                // 同梱チビ画像（最優先・確実）
                Image("chibi-\(id)")
                    .resizable()
                    .scaledToFit()
            } else if let data = entry.hatchedImageData, let uiImage = UIImage(data: data) {
                // 図鑑画像のネット取得フォールバック
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if isRevealDay {
                Text("🎊")
                    .font(.system(size: size * 0.8))
            } else {
                Text("🥚")
                    .font(.system(size: size * 0.8))
            }
        }
        .frame(width: size, height: size)
    }

    private var statsRow: some View {
        HStack {
            HStack(spacing: 3) {
                Image(systemName: "figure.walk")
                    .font(.caption)
                Text("\(snap.todaySteps)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            .foregroundStyle(.white.opacity(0.85))

        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.18))
                Capsule()
                    .fill(accentGreen)
                    .frame(width: max(6, geo.size.width * snap.progress))
            }
        }
        .frame(height: 6)
    }

    private var accentGreen: Color {
        Color(red: 0.42, green: 0.80, blue: 0.47)
    }
}

struct AyakasiWidget: Widget {
    let kind: String = "AyakasiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AyakasiWidgetEntryView(entry: entry)
                    .containerBackground(Color(red: 0.10, green: 0.11, blue: 0.10), for: .widget)
            } else {
                AyakasiWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color(red: 0.10, green: 0.11, blue: 0.10))
            }
        }
        .configurationDisplayName("妖怪のたまご")
        .description("歩いた分だけ卵が育ち、1万歩で妖怪がうまれます")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
