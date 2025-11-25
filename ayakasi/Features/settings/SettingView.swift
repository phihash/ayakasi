import SwiftUI
import StoreKit
import Kingfisher

struct SettingView: View {
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var authVM : AuthViewModel
    @State var isShowMailView = false
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
                }
                
                Section{
                    
                    HStack(spacing: 18){
                        Image(systemName: "note")
                        Link("プライバシーポリシー",destination: URL(string: "https://sizu.me/maili/posts/b3at3db2i5f1")!)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical,6)
                    
                    HStack(spacing: 18){
                        Image(systemName: "note")
                        Link("利用規約",destination: URL(string: "https://sizu.me/maili/posts/ae75vb8z0sso")!)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical,6)
                    
                    
                } header: {
                    Text("ポリシーと規約")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom,12)
                }
                
                Section{
                    
                    Button{
                        if MailView.canSendMail() {
                            isShowMailView = true
                        } else {
                            // MailViewを表示できない
                        }
                    } label : {
                        HStack(spacing: 18){
                            Image(systemName: "envelope")
                            Text("問い合わせ")
                        }
                        .padding(.vertical,6)
                    }
                    .foregroundStyle(.primary)
                } header : {
                    Text("問い合わせ")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom,12)
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
        .sheet(isPresented: $isShowMailView) {
            MailView(
                address: ["610g0531@gmail.com"],
                subject: "問い合わせ",
                body: "\n\n----\n不具合の検証に利用させていただきます。 \nApp: \(Bundle.main.appName)\n                    Version:  (\(Bundle.main.appVersion))   \n                     iOS: \(UIDevice.current.systemVersion)   \n"
            )
            .edgesIgnoringSafeArea(.all)
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
