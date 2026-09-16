import SwiftUI
import Kingfisher

/// 歩数で孵化した妖怪の一覧（孵化リスト）
struct HatchListView: View {
    @State private var records: [GrowthStore.HatchRecord] = []
    @State private var snapshot = GrowthStore.cachedSnapshot()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月d日"
        return f
    }()

    var body: some View {
        List {
            // 歩数が読めていない（許可を拒否された可能性大）→ 確認手順を案内
            if snapshot.setupDone && !snapshot.healthReadOK {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("歩数が読めていません", systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("ヘルスケアの読み取りが許可されていない可能性があります。\nヘルスケアアプリ → 共有 → App → ayakasi で「歩数」をオンにしてください。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 12) {
                            Button("ヘルスケアを開く") {
                                if let url = URL(string: "x-apple-health://") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            Button("再確認") {
                                Task {
                                    await HealthKitStepReader.requestAuthorization()
                                    _ = await HealthKitStepReader.refresh()
                                    snapshot = GrowthStore.cachedSnapshot()
                                }
                            }
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 4)
                }
            }

            // いまの卵の状態
            Section {
                HStack(spacing: 12) {
                    Text("🥚")
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("なにかのたまご")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        ProgressView(value: snapshot.progress)
                        Text("孵化まで あと\(snapshot.stepsToHatch)歩")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("うまれた妖怪 \(records.count)体") {
                if records.isEmpty {
                    Text("まだ妖怪はうまれていません。\n\(GrowthStore.hatchSteps)歩あるくと卵がかえります。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    // 新しい順に表示
                    ForEach(records.reversed()) { record in
                        if let yokai = ayakasis.first(where: { $0.documentId == record.documentId }) {
                            NavigationLink(destination: NeoDetail(yokai: yokai)) {
                                HStack(spacing: 12) {
                                    // ちびキャラ版を優先し、なければ図鑑画像にフォールバック
                                    KFImage(GrowthStore.chibiImageURL(for: yokai.documentId))
                                        .alternativeSources([URL(string: yokai.imageName).map { .network($0) }].compactMap { $0 })
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(yokai.name)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        Text(Self.dateFormatter.string(from: record.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("孵化リスト")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // この画面を開いたタイミングで歩数の読み取り許可を求める（文脈のある場所で出す）
            await HealthKitStepReader.requestAuthorization()
            // 最新の歩数を反映してから表示（孵化があればリストに現れる）
            _ = await HealthKitStepReader.refresh()
            snapshot = GrowthStore.cachedSnapshot()
            records = GrowthStore.hatchedRecords()
        }
    }
}
