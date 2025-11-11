//import SwiftUI
//
//struct RegisterView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    @EnvironmentObject var authVM : AuthViewModel
//    var body: some View {
//        VStack{
//            Text("新規登録")
//                .font(.system(size: 20, weight: .bold))
//            TextField("メールアドレス",text:$email)
//                .font(.system(size: 20, weight: .bold))
//                .textFieldStyle(.plain)
//                .padding(10)
//            SecureField("パスワード",text:$password)
//                .font(.system(size: 20, weight: .bold))
//                .textFieldStyle(.plain)
//                .padding(10)
//            SecureField("パスワード(確認)",text: $confirmPassword)
//                .font(.system(size: 20, weight: .bold))
//                .textFieldStyle(.plain)
//                .padding(10)
//            Button("登録"){
//                Task {
//                    await authVM.signUp()
//                }
//            }
//        }
//        .padding()
//    }
//}
