import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        VStack(spacing: 20){
            VStack{
                HStack{
                    Text("メールアドレス")
                        .fontWeight(.bold)
                    Spacer()
                }

                TextField("mail@example.com",text:$authVM.email)
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
                HStack{
                    Text("ログイン")
                        .frame(width: 160, height: 48)
                        .background(Color.appSecondary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onDisappear{
            authVM.email = ""
            authVM.password = ""
            authVM.message = ""
        }
        .navigationTitle("ログイン")
        .navigationBarTitleDisplayMode(.inline)
    }
}

