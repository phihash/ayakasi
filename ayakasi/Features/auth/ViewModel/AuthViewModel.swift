import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class AuthViewModel : ObservableObject{
    @Published var user : User?
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    private let authService = AuthService.shared
    
    init(){
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener(){
        self.user = authService.currentUser
        self.isAuthenticated = authService.isLogin
    }
    
    func signUp() async {
        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            print("全ての項目を入力してください")
            return
        }
        
        // パスワード一致チェック
        guard password == confirmPassword else {
            print("パスワードが一致しません")
            return
        }
        
        // パスワードの長さチェック（Firebaseは6文字以上必要）
        guard password.count >= 6 else {
            print("パスワードは6文字以上で入力してください")
            return
        }
        
        do{
            _ = try await authService.signUp(email: email, password: password)
            self.user = authService.currentUser
            self.isAuthenticated = authService.isLogin
            clearFields()
            print("登録成功！")
        } catch{
            print("登録エラー: \(error)")
        }
    }
    
    func signIn() async {
        guard !email.isEmpty &&  !password.isEmpty && !confirmPassword.isEmpty else {
            print("メールアドレスとパスワードを入力してください")
            return
        }
        
        do{
            _ = try await authService.signIn(email: email, password: password)
            self.user = authService.currentUser
            self.isAuthenticated = authService.isLogin
            clearFields()
            print("ログイン成功！")
            clearFields()
        } catch{
            print("ログインエラー: \(error)")
        }
    }
    
    func clearFields(){
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    func signOut() {
        do{
            try authService.signOut()
            self.user = nil
            self.isAuthenticated = false
            clearFields()
        } catch{
            print("ログアウトエラー")
        }
    }
}
