import SwiftUI
import StoreKit

struct Container: View {
    @State private var selection : Int = 0
    @State private var showSatisfactionAlert = false
    @State private var showContactForm = false
    @Environment(\.requestReview) var requestReview

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
            .onAppear {
                // 3回目の起動時に満足度アラートを表示
                if AppLaunchCounter.shared.handleAppLaunch() {
                    showSatisfactionAlert = true
                }
            }
            .alert("アプリは気に入っていますか？", isPresented: $showSatisfactionAlert) {
                Button("はい") {
                    // 満足しているユーザー → App Storeレビューへ
                    requestReview()
                    AppLaunchCounter.shared.markReviewRequested()
                }
                Button("いいえ") {
                    // 不満があるユーザー → 問い合わせページへ
                    showContactForm = true
                    AppLaunchCounter.shared.markReviewRequested()
                }
            } message: {
                Text("あなたのフィードバックをお聞かせください")
            }
            .sheet(isPresented: $showContactForm) {
                SafariView(url: URL(string: AppConstants.contactFormURL)!)
            }
        }
    }
}

