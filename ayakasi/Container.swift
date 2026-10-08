import SwiftUI

struct Container: View {
    @State private var selection : Int = 0
    @EnvironmentObject private var router: DeepLinkRouter
    @Environment(\.openURL) private var openURL
    @State private var updateURL: URL?
    @AppStorage("lastUpdatePromptAt") private var lastUpdatePromptAt = 0.0

    var body: some View {
        ZStack{
            TabView(selection: $selection) {

                SearchView()
                    .tabItem {
                        Image("search")
                            .renderingMode(.template)
                        Text("さがす")
                    }
                    .tag(0)

                JapanView()
                    .tabItem {
                        Image("map1")
                            .renderingMode(.template)
                        Text("マップ")
                    }
                    .tag(1)

                HomeView()
                    .tabItem {
                        Image("event1")
                            .renderingMode(.template)
                        Text("イベント")
                    }
                    .tag(2)

            }
            .tint(.appSecondary)
            .sheet(isPresented: $router.showSettings) {
                SettingView()
            }
            .onChange(of: router.pendingYokaiId) { _, newValue in
                // 通知タップで妖怪IDが来たら検索タブへ（SearchViewが遷移を消化する）
                if newValue != nil { selection = 0 }
            }
            .onOpenURL { url in
                guard url.scheme == "ayakasi" else { return }
                Analytics.trackAppOpened(source: "widget")
                switch url.host {
                case "start":
                    // 未セットアップWidgetのタップ → その場で歩数の許可を求める
                    Task {
                        await HealthKitStepReader.requestAuthorization()
                        await HealthKitStepReader.refresh()
                    }
                case "health":
                    // 「歩数が読めていません」Widgetのタップ → 設定シートを開きつつ再判定。
                    // 設定アプリで許可し直していれば、ここで読めるようになりWidgetも復帰する。
                    router.showSettings = true
                    Task {
                        await HealthKitStepReader.requestAuthorization()
                        await HealthKitStepReader.refresh()
                    }
                case "yokai":
                    // Widget/通知タップ (ayakasi://yokai/<documentId>) → 妖怪詳細へ
                    if let id = url.pathComponents.dropFirst().first {
                        router.pendingYokaiId = id
                    }
                default:
                    break
                }
            }
            .onChange(of: router.pendingEventURL) { _, newValue in
                // 通知タップでイベントURLが来たらイベントタブへ（HomeViewが消化する）
                if newValue != nil { selection = 2 }
            }
            .onChange(of: selection) { _, newValue in
                let tabNames = ["検索", "マップ", "イベント"]
                if newValue < tabNames.count {
                    Analytics.trackTabChanged(tabName: tabNames[newValue])
                    Analytics.trackScreenView(screenName: tabNames[newValue])
                }
            }
            .task {
                // アップデート確認は1日1回まで（更新がある時だけ案内を出す）
                let now = Date().timeIntervalSince1970
                guard now - lastUpdatePromptAt > 86_400 else { return }
                if let url = await UpdateChecker.appStoreURLIfOutdated() {
                    updateURL = url
                    lastUpdatePromptAt = now
                }
            }
            .alert("アップデートがあります", isPresented: Binding(
                get: { updateURL != nil },
                set: { if !$0 { updateURL = nil } }
            )) {
                Button("更新する") {
                    if let updateURL { openURL(updateURL) }
                }
                Button("あとで", role: .cancel) { updateURL = nil }
            } message: {
                Text("最新バージョンがApp Storeで公開されています。")
            }
        }
    }
}

enum UpdateChecker {
    /// iTunes Lookup APIで最新版を取得し、現在のアプリより新しければApp StoreのURLを返す。
    /// ponytail: 任意アップデートの案内のみ。強制アップデートが要るならRemote Config等で最低バージョンを配信して判定に差し替え
    static func appStoreURLIfOutdated() async -> URL? {
        guard let bundleId = Bundle.main.bundleIdentifier,
              let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let lookupURL = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=jp") else {
            return nil
        }
        guard let (data, _) = try? await URLSession.shared.data(from: lookupURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let first = results.first,
              let latest = first["version"] as? String,
              let storeURLString = first["trackViewUrl"] as? String,
              let storeURL = URL(string: storeURLString) else {
            return nil
        }
        // "3.21.0" > "3.9.0" を正しく判定するため数値比較
        guard current.compare(latest, options: .numeric) == .orderedAscending else { return nil }
        return storeURL
    }
}
