import SwiftUI

struct Container: View {
    @State private var selection : Int = 0
    @EnvironmentObject private var router: DeepLinkRouter

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
        }
    }
}
