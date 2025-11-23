import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM : AuthViewModel
    @EnvironmentObject var colorVM : ColorViewModel
    var body: some View {
        NavigationStack{
            VStack{
                if authVM.authStatus == .none{
                    Group{
                        Text("新規登録")
                            .font(.system(size: 20, weight: .bold))
                        TextField("メールアドレス",text:$authVM.email)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        
                        SecureField("パスワード",text:$authVM.password)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        
                        SecureField("パスワード(確認)",text: $authVM.confirmPassword)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        
                        Text(authVM.message)
                            .foregroundStyle(.red)
                            .font(.title3)
                        
                        Button {
                            Task {
                                await authVM.signUp()
                            }
                        } label : {
                            HStack{
                                Text("登録")
                                    .frame(width: 160, height: 48)
                                    .background(colorVM.currentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                    }
                }
                else if authVM.authStatus == .waitingVerification{
                    VStack(spacing: 20) {
                        Text("メールを確認し、認証してください。")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("メールが届いていない時は、迷惑メールリストを確認してください")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        
                        Button(action: {
                            Task {
                                await authVM.checkEmailVerification()
                                if authVM.authStatus == .authenticated {
                                    dismiss()
                                }
                            }
                        }) {
                            Text("認証を確認")
                                .frame(width: 160, height: 48)
                                .background(colorVM.currentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            Task {
                                await authVM.resendVerificationEmail()
                            }
                        }) {
                            Text("認証メールを再送信")
                                .foregroundColor(colorVM.currentColor)
                        }
                    }
                }
                
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing ){
                    Button("閉じる"){
                        dismiss()
                    }
                }
            }
        }
    }
}
