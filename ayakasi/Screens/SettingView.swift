import SwiftUI
import StoreKit


struct SettingView: View {
    @Environment(\.requestReview) var requestReview
    @State var isShowMailView = false
    var body: some View {
        NavigationStack{
            List{
                Section{
                   
                    NavigationLink(destination: ColorView() ){
                        HStack(spacing: 18){
                            Image(systemName: "paintpalette")
                            Text("カラー変更")
                        }
                        .foregroundStyle(.black)
                        .padding(.vertical,6)
                    }
                    

                    HStack(spacing: 12){
                        ShareLink(item: URL(string: "https://apps.apple.com/jp/app/%E5%A6%96%E6%80%AA%E5%9B%B3%E9%91%91/id6749905503")!) {
                            HStack(spacing: 18){
                                Image(systemName: "star.fill")
                                Text("アプリを共有する")
                            }
                            .foregroundStyle(.black)
                        }
                    }
                   
                    Button{
                        requestReview()
                    } label : {
                        HStack(spacing: 18){
                            Image(systemName: "star")
                            Text("アプリを評価する")
                        }
                        .foregroundStyle(.black)
                        .padding(.vertical,6)
                    }
                } header : {
                    Text("アプリ")
                        .font(.title3)
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .padding(.bottom,12)
                }
                
                Section{
                    
                    HStack(spacing: 18){
                        Image(systemName: "note")
                        Link("プライバシーポリシー",destination: URL(string: "https://sizu.me/maili/posts/b3at3db2i5f1")!)
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical,6)
                    
                    HStack(spacing: 18){
                        Image(systemName: "note")
                        Link("利用規約",destination: URL(string: "https://sizu.me/maili/posts/ae75vb8z0sso")!)
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical,6)
                    
                    
                } header: {
                    Text("ポリシーと規約")
                        .font(.title3)
                        .foregroundStyle(.black)
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
                            Image(systemName: "mail")
                            Text("問い合わせ")
                        }
                        .foregroundStyle(.black)
                        .padding(.vertical,6)
                    }
                } header : {
                    Text("問い合わせ")
                        .font(.title3)
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .padding(.bottom,12)
                }
                
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isShowMailView) {
                    MailView(
                        address: ["610g0531@gmail.com"],
                        subject: "問い合わせ",
                        body: "\n\n----\n不具合の検証に利用させていただきます。 \nApp: \(Bundle.main.appName)\n                    Version:  (\(Bundle.main.appVersion))   \n                     iOS: \(UIDevice.current.systemVersion)   \n"
                    )
                    .edgesIgnoringSafeArea(.all)
                }
    }
}


