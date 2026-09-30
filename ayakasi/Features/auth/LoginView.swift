import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM : AuthViewModel
    @State private var showResetConfirm = false
    @FocusState private var emailFocused: Bool
    var body: some View {
        VStack(spacing: 20){
            VStack(spacing: 8) {
                Text("おかえりなさい")
                    .font(.title2.bold())
                Text("メールアドレスでログイン")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 32)
            .padding(.bottom, 12)

            VStack{
                HStack{
                    Text("メールアドレス")
                        .fontWeight(.bold)
                    Spacer()
                }

                TextField("mail@example.com",text:$authVM.email)
                    .focused($emailFocused)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .font(.system(size: 18))
                    .padding()
                    .background(Color.appTextFieldBackground)
                    .cornerRadius(10)
                    .contentShape(Rectangle())

            }
            .padding(.horizontal)
            
            VStack{
                HStack{
                    Text("パスワード")
                        .fontWeight(.bold)
                    Spacer()
                }
                
                SecureField("6文字以上",text:$authVM.password)
                    .textContentType(.password)
                    .font(.system(size: 18))
                    .padding()
                    .background(Color.appTextFieldBackground)
                    .cornerRadius(10)
                    .contentShape(Rectangle())
            }
            .padding(.horizontal)

            HStack {
                Spacer()
                Button("パスワードをお忘れですか？") {
                    if authVM.email.isEmpty {
                        authVM.message = "再設定にはメールアドレスの入力が必要です"
                        emailFocused = true
                    } else {
                        showResetConfirm = true
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.appSecondary)
            }
            .padding(.horizontal)

            Text(authVM.message)
                .foregroundStyle(Color.appError)
                .font(.subheadline)

            Button {
                Task {
                    await authVM.signIn()
                    if authVM.authStatus == .authenticated {
                        dismiss()
                    }
                }
            } label : {
                Text("ログイン")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.appSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()
        }
        .onDisappear{
            authVM.email = ""
            authVM.password = ""
            authVM.message = ""
        }
        .alert("パスワード再設定", isPresented: $showResetConfirm) {
            Button("送信") { Task { await authVM.forgotPassword() } }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("\(authVM.email) に再設定メールを送信します")
        }
        .navigationTitle("ログイン")
        .navigationBarTitleDisplayMode(.inline)
    }
}

