import SwiftUI
import StoreKit
import Kingfisher

struct SettingView: View {
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var authVM : AuthViewModel
    @State var isShowRegisterView = false
    @State var isShowLoginView = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    var body: some View {
        NavigationStack{
            VStack{
                if authVM.authStatus != .authenticated {
                    Button{
                        isShowRegisterView = true
                    } label: {
                        HStack{
                            HStack(spacing: 18){
                                Image(systemName: "person.crop.circle")
                                Text("新規登録")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .padding(.vertical,2)
                    }
                    .foregroundStyle(.primary)
                    
                    Button{
                        isShowLoginView = true
                    } label: {
                        HStack{
                            HStack(spacing: 18){
                                Image(systemName: "person.circle")
                                Text("ログイン")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        
                        .padding(.vertical,2)
                    }
                    .foregroundStyle(.primary)
                    if authVM.authStatus == .authenticated {
                        
                        Button{
                            showLogoutAlert = true
                        } label: {
                            HStack{
                                HStack(spacing: 18){
                                    Image(systemName: "person.crop.circle.badge.moon")
                                    Text("ログアウト")
                                        .font(.subheadline)
                                }
                                Spacer()
                            }
                            
                            .padding(.vertical,2)
                        }
                        .foregroundStyle(.primary)
                        
                        Button{
                            showDeleteAccountAlert = true
                        } label: {
                            HStack{
                                HStack(spacing: 18){
                                    Image(systemName: "trash")
                                    Text("アカウント削除")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.red)
                                Spacer()
                            }
                            
                            .padding(.vertical,2)
                        }
                        .foregroundStyle(.primary)
                    }
                    
                }
            }
            .padding(.horizontal,8)
            
            List{
                
                
                HStack{
                    HStack(spacing: 18){
                        Image(systemName: "tag")
                        Text("現在のバージョン")
                    }
                    Spacer()
                    Text(Bundle.main.appVersion)
                }
                .foregroundStyle(.primary)
                .padding(.vertical,6)
                
                
                
                
                
                
                NavigationLink(destination: FavoriteYokaiView()) {
                    HStack(spacing: 18){
                        Image(systemName: "star.fill")
                        Text("お気に入り一覧")
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical,6)
                }
                
                
                Button{
                    KingfisherManager.shared.cache.clearMemoryCache()
                    KingfisherManager.shared.cache.clearDiskCache()
                } label : {
                    HStack(spacing: 18){
                        Image(systemName: "trash")
                        Text("キャッシュを削除する")
                    }
                    .padding(.vertical,6)
                }
                .foregroundStyle(.primary)
                
                HStack(spacing: 12){
                    ShareLink(item: URL(string: "https://apps.apple.com/jp/app/%E5%A6%96%E6%80%AA%E5%9B%B3%E9%91%91/id6749905503")!) {
                        HStack(spacing: 18){
                            Image(systemName: "star.fill")
                            Text("アプリを共有する")
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                Button{
                    requestReview()
                } label : {
                    HStack(spacing: 18){
                        Image(systemName: "star")
                        Text("アプリを評価する")
                    }
                    .padding(.vertical,6)
                }
                .foregroundStyle(.primary)
                
                
                NavigationLink(destination: WebView(url: URL(string: AppConstants.contactFormURL))) {
                    HStack(spacing: 18){
                        Image(systemName: "envelope")
                        Text("匿名で問い合わせ")
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical,6)
                }
                
                
                
                
                NavigationLink(destination: WebView(url: URL(string: AppConstants.privacyPolicyURL))) {
                    HStack(spacing: 18){
                        Image(systemName: "note")
                        Text("プライバシーポリシー")
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical,6)
                }
                
                NavigationLink(destination: WebView(url: URL(string: AppConstants.termsOfServiceURL))) {
                    HStack(spacing: 18){
                        Image(systemName: "note")
                        Text("利用規約")
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical,6)
                }
                
                
                
                
                
                
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented:$isShowRegisterView){
            RegisterView()
        }
        .fullScreenCover(isPresented:$isShowLoginView){
            LoginView()
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
    }
}
