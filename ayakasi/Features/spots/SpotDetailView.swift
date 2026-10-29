import SwiftUI
import Kingfisher

/// ゆかりの地に行った人が残すログ(写真＋文章)
struct SpotLog: Identifiable {
    let id = UUID()
    let photoURL: URL?
    let visitedAt: Date
    let title: String
    let body: String

    // ponytail: UIを先に作るための仮データ。D1の spot_logs とアップロードAPIができたら差し替える
    static func samples(for spot: YokaiSpot) -> [SpotLog] {
        let photo = spot.yokaiIds.first.flatMap(yokaiById).flatMap { URL(string: $0.imageName) }
        return [
            SpotLog(photoURL: photo, visitedAt: .now.addingTimeInterval(-86400 * 3),
                    title: "思っていたより静かな場所",
                    body: "駅から歩いて20分ほど。案内板があるので迷いませんでした。\n夕方に行ったら人がいなくて、少しひんやりした空気でした。"),
            SpotLog(photoURL: photo, visitedAt: .now.addingTimeInterval(-86400 * 40),
                    title: "御朱印もいただけました",
                    body: "近くに資料館もあるので、あわせて回るのがおすすめです。"),
        ]
    }
}

extension DateFormatter {
    static let logDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}

struct SpotDetailView: View {
    let spot: YokaiSpot
    @State private var logs: [SpotLog] = []
    @State private var selectedYokai: Ayakasi?
    @State private var selectedLog: SpotLog?
    @State private var showLoginAlert = false
    @EnvironmentObject var authVM: AuthViewModel

    private var relatedYokais: [Ayakasi] { spot.yokaiIds.compactMap(yokaiById) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let description = spot.description {
                    Text(description)
                        .lineSpacing(6)
                        .foregroundStyle(Color.appTextPrimary)
                }
                if !relatedYokais.isEmpty { yokaiRow }
                LazyVStack(spacing: 16) {
                    ForEach(logs) { log in
                        // メニューをButtonのlabelの外に重ねるのは、labelの中のMenuはタップがカードの遷移に取られるため
                        Button { selectedLog = log } label: { SpotLogCard(log: log) }
                            .buttonStyle(.plain)
                            .overlay(alignment: .topTrailing) {
                                if authVM.authStatus == .authenticated {
                                    SpotLogMenu()
                                        .background(Circle().fill(.ultraThinMaterial))
                                        .padding(24)
                                }
                            }
                    }
                }
                .padding(.horizontal, -8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .background(Color.appBackground)
        .overlay(alignment: .bottom) { addLogBar }
        .navigationTitle("ゆかりの地")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $selectedYokai) { yokai in
            NeoDetail(yokai: yokai, source: "spot")
        }
        .navigationDestination(item: $selectedLog) { log in
            SpotLogDetailView(log: log, spot: spot)
        }
        .task { logs = SpotLog.samples(for: spot) }
        .alert("ログインが必要です", isPresented: $showLoginAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("ログを追加するには、設定画面からログインまたは新規登録してください。")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SegmentTag(left: "ゆかりの地", right: spot.prefecture)
                Spacer()
                Button {
                    let url = "https://www.google.com/maps/search/?api=1&query=\(spot.coordinate.latitude),\(spot.coordinate.longitude)"
                    URL(string: url).map { UIApplication.shared.open($0) }
                } label: {
                    Label("地図で開く", systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .underline()
                        .foregroundStyle(Color.appSecondary)
                }
            }
            Text(spot.spotName)
                .font(.title2.bold())
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    private var yokaiRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(relatedYokais) { yokai in
                    Button { selectedYokai = yokai } label: {
                        HStack(spacing: 8) {
                            YokaiThumbnail(yokai: yokai, size: 36)
                            Text(yokai.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(6)
                        .padding(.trailing, 6)
                        .background(Capsule().fill(Color.appCardBackground))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var addLogBar: some View {
        Button {
            guard authVM.authStatus == .authenticated else {
                showLoginAlert = true
                return
            }
            // ponytail: 投稿画面は写真アップロードAPIと一緒に作る
        } label: {
            HStack {
                Text("ログを追加")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.appSecondary))
            }
            .padding(.leading, 24)
            .padding(6)
            .background(Capsule().fill(Color.appCardBackground))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

/// 「食べる｜スイーツ」のような左が塗り・右が枠の2つ組タグ
struct SegmentTag: View {
    let left: String
    let right: String

    var body: some View {
        HStack(spacing: 0) {
            Text(left)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appSecondary)
            Text(right)
                .foregroundStyle(Color.appSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .font(.caption.weight(.semibold))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.appSecondary, lineWidth: 1))
    }
}

private struct SpotLogCard: View {
    let log: SpotLog

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LogPhoto(url: log.photoURL)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottomLeading) {
                    Text(DateFormatter.logDate.string(from: log.visitedAt))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                        .padding(12)
                }
            Text(log.title)
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)
            Text(log.body)
                .font(.subheadline)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

struct SpotLogDetailView: View {
    let log: SpotLog
    let spot: YokaiSpot
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                LogPhoto(url: log.photoURL)
                    .frame(height: 420)
                    .clipped()
                    .overlay {
                        LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(DateFormatter.logDate.string(from: log.visitedAt))
                            SegmentTag(left: "ゆかりの地", right: spot.prefecture)
                                .background(RoundedRectangle(cornerRadius: 6).fill(.white))
                            Text(spot.spotName)
                                .font(.title2.bold())
                        }
                        .foregroundStyle(.white)
                        .padding(20)
                    }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        Text(log.title)
                            .font(.title2.bold())
                        Spacer()
                        if authVM.authStatus == .authenticated {
                            SpotLogMenu()
                        }
                    }
                    Text(log.body)
                        .lineSpacing(6)
                }
                .foregroundStyle(Color.appTextPrimary)
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .tabBar)
    }
}

private struct LogPhoto: View {
    let url: URL?

    var body: some View {
        Color.gray.opacity(0.12)
            .overlay {
                KFImage(url)
                    .downsampling(size: CGSize(width: 800, height: 800))
                    .scaleFactor(UIScreen.main.scale)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }
}

/// コメントの CommentMenu と同じ「…」(通報・ブロック)
private struct SpotLogMenu: View {
    var body: some View {
        Menu {
            // ponytail: 見た目だけ。spot_logs の通報・ブロックAPIができたら CommentMenu と同じ確認ダイアログをつなぐ
            Button("ログを報告する", systemImage: "exclamationmark.triangle", role: .destructive) {}
            Button("ユーザーをブロックする", systemImage: "person.fill.xmark", role: .destructive) {}
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("ログのメニュー")
    }
}

extension SpotLog: Hashable {
    static func == (lhs: SpotLog, rhs: SpotLog) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
