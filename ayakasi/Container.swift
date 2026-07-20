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
                    }
                    .tag(0)
                
                CommunityView()
                    .tabItem {
                        Image("conversation")
                            .renderingMode(.template)
                    }
                    .tag(1)
                
                JapanView()
                    .tabItem {
                        Image("map1")
                            .renderingMode(.template)
                    }
                    .tag(2)
                
                HomeView()
                    .tabItem {
                        Image("event1")
                            .renderingMode(.template)
                    }
                    .tag(3)
                
                
                SettingView()
                    .tabItem {
                        Image("setting")
                            .renderingMode(.template)
                    }
                    .tag(4)
                
            }
            .tint(.appSecondary)
            .onChange(of: router.pendingYokaiId) { _, newValue in
                // 通知タップで妖怪IDが来たら検索タブへ（SearchViewが遷移を消化する）
                if newValue != nil { selection = 0 }
            }
            .onChange(of: router.pendingEventURL) { _, newValue in
                // 通知タップでイベントURLが来たらイベントタブへ（HomeViewが消化する）
                if newValue != nil { selection = 3 }
            }
            .onChange(of: selection) { _, newValue in
                let tabNames = ["検索", "コミュニティ", "マップ", "イベント", "設定"]
                if newValue < tabNames.count {
                    Analytics.trackTabChanged(tabName: tabNames[newValue])
                    Analytics.trackScreenView(screenName: tabNames[newValue])
                }
            }
        }
    }
}
