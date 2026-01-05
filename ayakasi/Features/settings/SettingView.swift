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
            List{
                Section{
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
                    
                    
                    if authVM.authStatus != .authenticated {
                        Button{
                            isShowRegisterView = true
                        } label: {
                            HStack{
                                HStack(spacing: 18){
                                    Image(systemName: "person.crop.circle")
                                    Text("新規登録")
                                }
                                Spacer()
                            }
                            
                            .padding(.vertical,6)
                        }
                        .foregroundStyle(.primary)
                        
                        Button{
                            isShowLoginView = true
                        } label: {
                            HStack{
                                HStack(spacing: 18){
                                    Image(systemName: "person.circle")
                                    Text("ログイン")
                                }
                                Spacer()
                            }
                            
                            .padding(.vertical,6)
                        }
                        .foregroundStyle(.primary)
                        

                    }
                    
                    if authVM.authStatus == .authenticated {
                        Button{
                            showLogoutAlert = true
                        } label: {
                            HStack{
                                HStack(spacing: 18){
                                    Image(systemName: "person.crop.circle.badge.moon")
                                    Text("ログアウト")
                                }
                                Spacer()
                            }
                            
                            .padding(.vertical,6)
                        }
                        .foregroundStyle(.primary)
                        
                        Button{
                            showDeleteAccountAlert = true
                        } label: {
                            HStack{
                                HStack(spacing: 18){
                                    Image(systemName: "trash")
                                    Text("アカウント削除")
                                }
                                .foregroundStyle(.red)
                                Spacer()
                            }
                            
                            .padding(.vertical,6)
                        }
                        .foregroundStyle(.primary)
                    }
               
                  
                    NavigationLink(destination: ColorView() ){
                        HStack(spacing: 18){
                            Image(systemName: "paintpalette")
                            Text("カラー変更")
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
                } header : {
                    Text("アプリ")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom,12)
                        .padding(.leading, -10)
                }
                
                Section{
                    NavigationLink(destination: WebView(url: URL(string: "https://forms.gle/3e4DGw8CPY3VrJTJ9"))) {
                        HStack(spacing: 18){
                            Image(systemName: "envelope")
                            Text("匿名で問い合わせ")
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical,6)
                    }
                } header : {
                    Text("問い合わせ")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom,12)
                        .padding(.leading, -10)
                }
                
                Section{
                    
                    NavigationLink(destination: WebView(url: URL(string: "https://sizu.me/maili/posts/b3at3db2i5f1"))) {
                        HStack(spacing: 18){
                            Image(systemName: "note")
                            Text("プライバシーポリシー")
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical,6)
                    }
                    
                    NavigationLink(destination: WebView(url: URL(string: "https://sizu.me/maili/posts/ae75vb8z0sso"))) {
                        HStack(spacing: 18){
                            Image(systemName: "note")
                            Text("利用規約")
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical,6)
                    }
                    
                    
                } header: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ポリシーと規約")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.bottom,12)
                    .padding(.leading, -10)
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
