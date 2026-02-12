import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        NavigationStack{
            VStack{
                Text("ログイン")
                    .font(.system(size: 20, weight: .bold))
                VStack{
                    TextField("メールアドレス",text:$authVM.email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .font(.system(size: 18))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                        .padding(.horizontal)
                    
                    SecureField("パスワード",text:$authVM.password)
                        .textContentType(.password)
                        .font(.system(size: 18))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .contentShape(Rectangle())  // タップ領域を拡大
                        .padding(.horizontal)
                }
                
                
                Text(authVM.message)
                    .foregroundStyle(.red)
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
                            .background(.blue)
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

