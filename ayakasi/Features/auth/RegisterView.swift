import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                // 閉じるボタン
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("閉じる")
                    }
                }
                .padding(.trailing, 4)
                
                Spacer()

                if authVM.authStatus == .none{
                    Group{
                        TextField("メールアドレス",text:$authVM.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color.appTextFieldBackground)
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        
                        SecureField("パスワード",text:$authVM.password)
                            .textContentType(.password)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color.appTextFieldBackground)
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        
                        SecureField("パスワード(確認)",text: $authVM.confirmPassword)
                            .textContentType(.password)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color.appTextFieldBackground)
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        
                        Text(authVM.message)
                            .foregroundStyle(Color.appError)
                            .font(.title3)
                        
                        Button {
                            Task {
                                await authVM.signUp()
                            }
                        } label : {
                            HStack{
                                Text("登録")
                                    .frame(width: 160, height: 48)
                                    .background(Color.appSecondary)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text("登録すると利用規約およびプライバシーポリシーに同意したものとみなされます。")
                                .font(.subheadline)
                                .foregroundColor(.appTextPrimary)
                                .padding(.horizontal,12)
                            
                            HStack(spacing: 20) {
                                NavigationLink(destination: WebView(url: URL(string: AppConstants.termsOfServiceURL))) {
                                    Text("利用規約")
                                        .font(.subheadline)
                                        .foregroundColor(.appSecondary)
                                }
                                
                                NavigationLink(destination: WebView(url: URL(string: AppConstants.privacyPolicyURL))) {
                                    Text("プライバシーポリシー")
                                        .font(.subheadline)
                                        .foregroundColor(.appSecondary)
                                }
                            }
                        }
                        .padding(.horizontal,12)
                        .padding(.vertical,8)
                        
                        
                    }
                }
                else if authVM.authStatus == .waitingVerification{
                    VStack(spacing: 20) {
                        Text("認証メールを送信しました")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("メールが届いていない時は、迷惑メールリストを確認してください")
                            .font(.subheadline)
                            .foregroundStyle(Color.appError)
                        
                        Button(action: {
                            Task {
                                await authVM.checkEmailVerification()
                                if authVM.authStatus == .authenticated {
                                    dismiss()
                                }
                            }
                        }) {
                            Text("メールを確認した")
                                .frame(width: 160, height: 48)
                                .background(Color.appSecondary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            Task {
                                await authVM.resendVerificationEmail()
                            }
                        }) {
                            Text("認証メールを再送信")
                                .foregroundColor(.appSecondary)
                        }
                    }
                }

            }
            .onDisappear{
                authVM.email = ""
                authVM.password = ""
                authVM.message = ""
            }
            .navigationTitle("新規登録")
            .navigationBarTitleDisplayMode( .inline)
        }
    }
}
