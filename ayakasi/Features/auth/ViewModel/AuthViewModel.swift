import Foundation
import SwiftUI
import FirebaseAuth

enum AuthStatus {
    case none              // 何もしてない
    case waitingVerification  // 新規登録済みだがメール認証待ち
    case authenticated     // 認証済み（ログイン済み）
}



@MainActor
class AuthViewModel : ObservableObject{
    
    @Published var user : User?
    @Published var authStatus: AuthStatus = .none
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var message = ""
    @Published var isShowLoginView: Bool = false
    @Published var isShowRegisterView: Bool = false

    private let authService = AuthService.shared

    init(){
        setupAuthStateListener()

        // 既存ユーザーがいればusersドキュメントを確保
        Task {
            await authService.ensureUserExists()
        }
    }
    
    func showLogin() {
        isShowLoginView = true
    }

    func showRegister() {
        isShowRegisterView = true
    }
    
    private func setupAuthStateListener(){
        self.user = authService.currentUser
        
        if authService.currentUser == nil {
            self.authStatus = .none
        } else if authService.isEmailVerified {
            self.authStatus = .authenticated
        } else {
            self.authStatus = .waitingVerification
        }
    }
    
    func signUp() async {
        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            message = "全ての項目を入力してください"
            return
        }
        
        // パスワード一致チェック
        guard password == confirmPassword else {
            message = "パスワードが一致しません"
            return
        }
        
        // パスワードの長さチェック（Firebaseは6文字以上必要）
        guard password.count >= 6 else {
            message = "パスワードは6文字以上で入力してください"
            return
        }
        
        do{
            self.user =  try await authService.signUpWithEmailVerification(email: email, password: password)
            self.authStatus = .waitingVerification
            clearFields()
            message = "認証メールを送信しました"
            print("登録成功！認証メールを送信しました。")
            
            // 新規登録時にusersコレクションを作成
            Task {
                await authService.ensureUserExists()
            }
        } catch{
            print("登録エラー: \(error)")
            if let authError = error as NSError? {
                switch authError.code {
                case 17007: // ERROR_EMAIL_ALREADY_IN_USE
                    message = "このメールアドレスは既に登録されています"
                case 17008: // ERROR_INVALID_EMAIL
                    message = "メールアドレスの形式が正しくありません"
                case 17026: // ERROR_WEAK_PASSWORD
                    message = "パスワードが弱すぎます"
                default:
                    message = "登録エラーが発生しました"
                }
            }
        }
    }
    
    func clearFields(){
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    func signIn() async {
        guard !email.isEmpty && !password.isEmpty else {
            message = "メールアドレスとパスワードを入力してください"
            return
        }
        
        do{
            self.user = try await authService.signIn(email: email, password: password)
            
            if authService.isEmailVerified {
                self.authStatus = .authenticated
                message = ""
                clearFields()
                print("ログイン成功！")
                
                // ログイン時にusersコレクションを確保
                Task {
                    await authService.ensureUserExists()
                }
            } else {
                self.authStatus = .waitingVerification
                message = "メールアドレスの認証が完了していません"
            }
        } catch{
            print("ログインエラー: \(error)")
            if let authError = error as NSError? {
                switch authError.code {
                case 17009: // ERROR_USER_NOT_FOUND
                    message = "このメールアドレスは登録されていません"
                case 17011: // ERROR_WRONG_PASSWORD
                    message = "パスワードが間違っています"
                case 17008: // ERROR_INVALID_EMAIL
                    message = "メールアドレスの形式が正しくありません"
                default:
                    message = "ログインエラーが発生しました"
                }
            }
        }
    }
    
    func deleteAccount() async {
        do {
            try await authService.deleteUser()
            self.user = nil
            self.authStatus = .none
            clearFields()
        } catch {
            print("アカウント削除失敗: \(error)")
        }
    }

    
    func signOut() {
        do{
            try authService.signOut()
            self.user = nil
            self.authStatus = .none
            clearFields()
        } catch{
            print("ログアウトエラー")
        }
    }
    
    // メール認証状態を再チェック
    func checkEmailVerification() async {
        do {
            try await authService.reloadUser()
            self.user = authService.currentUser
            
            if authService.currentUser == nil {
                self.authStatus = .none
            } else if authService.isEmailVerified {
                self.authStatus = .authenticated
            } else {
                self.authStatus = .waitingVerification
            }
        } catch {
            print("ユーザー情報の更新エラー: \(error)")
        }
    }
    
    // 認証メールの再送信
    func resendVerificationEmail() async {
        do {
            try await authService.sendEmailVerification()
            print("認証メールを再送信しました")
        } catch {
            print("メール再送信エラー: \(error)")
        }
    }
}
