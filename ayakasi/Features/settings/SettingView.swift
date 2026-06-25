import SwiftUI
import Kingfisher
import UIKit

struct SettingView: View {
    @EnvironmentObject var authVM : AuthViewModel
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showClearCacheAlert = false
    @State private var currentAppIconName = UIApplication.shared.alternateIconName
    @AppStorage("isDarkMode") private var isDarkMode = false

    private var settingIconImageName: String {
        switch currentAppIconName {
        case "KappaIcon":
            return "kappaicon1"
        case "RokuroIcon":
            return "rokuroicon"
        default:
            return "settingIcon"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(settingIconImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        Text("妖怪図鑑")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Version \(Bundle.main.appVersion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    

                    VStack(spacing: 0) {
                        SettingRowLink(title: "匿名で問い合わせ", destination: WebView(url: URL(string: AppConstants.contactFormURL)))
                            .simultaneousGesture(TapGesture().onEnded {
                                Analytics.trackScreenView(screenName: "匿名で問い合わせ")
                            })

                        NavigationLink(destination: MessageUI()) {
                            HStack {
                                Text("みなさんの声")
                                    .font(.subheadline)
                                if Message.hasNewMessage {
                                    Text("NEW")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.red)
                                        .cornerRadius(4)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 12)
                        }
                        .foregroundStyle(.primary)
                        .simultaneousGesture(TapGesture().onEnded {
                            Analytics.trackScreenView(screenName: "みなさんの声")
                        })

                        SettingRowLink(title: "プライバシーポリシー", destination: WebView(url: URL(string: AppConstants.privacyPolicyURL)))
          
                        SettingRowLink(title: "利用規約", destination: WebView(url: URL(string: AppConstants.termsOfServiceURL)))
                        Divider()
                            .padding(.leading, 4)
                            .padding(.vertical, 12)
                        
                        if authVM.authStatus != .authenticated {
                            SettingRowLink(title: "新規登録", destination: RegisterView())

                            SettingRowLink(title: "ログイン", destination: LoginView())
                        }

                        if authVM.authStatus == .authenticated {
                            SettingRowButton(title: "ログアウト") {
                                showLogoutAlert = true
                            }

                            SettingRowButton(title: "アカウント削除", color: .appError) {
                                showDeleteAccountAlert = true
                            }
                           
                        }


                        Divider()
                            .padding(.leading, 4)
                            .padding(.vertical, 12)

                        SettingRowToggle(title: "ダークモード", isOn: $isDarkMode)

                        SettingRowLink(title: "アプリアイコン", destination: IconSelect())

                        Button(action: {}) {
                            ShareLink(item: URL(string: "https://apps.apple.com/jp/app/%E5%A6%96%E6%80%AA%E5%9B%B3%E9%91%91/id6749905503")!) {
                                HStack {
                                    Text("アプリを共有する")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                            }
                        }
                        .foregroundStyle(.primary)

                        SettingRowLink(title: "ブックマーク一覧", destination: FavoriteYokaiView())
                        
                        SettingRowButton(title: "キャッシュを削除する") {
                            showClearCacheAlert = true
                        }

     
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            currentAppIconName = UIApplication.shared.alternateIconName
        }
        .onReceive(NotificationCenter.default.publisher(for: .appIconDidChange)) { _ in
            currentAppIconName = UIApplication.shared.alternateIconName
        }
        .alert("ログアウトしますか？", isPresented: $showLogoutAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("ログアウト", role: .destructive) {
                authVM.signOut()
            }
        } message: {
            Text("ログアウトすると、再度ログインが必要になります。")
        }
        .alert("アカウントを削除しますか？", isPresented: $showDeleteAccountAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                Task {
                    await authVM.deleteAccount()
                }
            }
        } message: {
            Text("この操作は取り消すことができません。すべてのデータが削除されます。")
        }
        .alert("キャッシュを削除しますか？", isPresented: $showClearCacheAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                KingfisherManager.shared.cache.clearMemoryCache()
                KingfisherManager.shared.cache.clearDiskCache()
            }
        } message: {
            Text("画像キャッシュが削除されます。")
        }
    }
}
