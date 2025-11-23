import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        VStack{
            Text("ログイン")
                .font(.system(size: 20, weight: .bold))
            TextField("メールアドレス",text:$email)
                .font(.system(size: 20, weight: .bold))
                .textFieldStyle(.plain)
                .padding(10)
            SecureField("パスワード",text:$password)
                .font(.system(size: 20, weight: .bold))
                .textFieldStyle(.plain)
                .padding(10)
            
            Button("ログイン"){
                Task{
                    await authVM.signIn()
                }
            }
        }
        .padding()
        
    }
}

