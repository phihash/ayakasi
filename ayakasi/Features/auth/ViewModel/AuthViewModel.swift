import Foundation
import SwiftUI
import FirebaseAuth
import os

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
    @Published var deleteErrorMessage: String?
    @Published var isProcessing = false

    private let authService = AuthService.shared
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init(){
        setupAuthStateListener()

        // 既存ユーザーがいればusersドキュメントを確保
        Task {
            await authService.ensureUserExists()
        }
    }

    deinit {
        if let authStateHandle {
            authService.removeAuthStateListener(authStateHandle)
        }
    }
    
    func showLogin() {
        isShowLoginView = true
    }

    func showRegister() {
        isShowRegisterView = true
    }
    
    private func setupAuthStateListener(){
        authStateHandle = authService.observeAuthState { [weak self] user in
            self?.applyAuthState(user)
        }
    }

    private func applyAuthState(_ user: User?) {
        self.user = user

        if user == nil {
            self.authStatus = .none
        } else if user?.isEmailVerified == true {
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

        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        do{
            self.user =  try await authService.signUpWithEmailVerification(email: email, password: password)
            self.authStatus = .waitingVerification
            clearFields()
            message = "認証メールを送信しました"

            // 新規登録時にusersコレクションを作成
            Task {
                await authService.ensureUserExists()
            }
        } catch{
            Logger.auth.error("登録エラー: \(String(describing: error))")
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

        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        do{
            self.user = try await authService.signIn(email: email, password: password)
            
            if authService.isEmailVerified {
                self.authStatus = .authenticated
                message = ""
                clearFields()

                // ログイン時にusersコレクションを確保
                Task {
                    await authService.ensureUserExists()
                }
            } else {
                self.authStatus = .waitingVerification
                message = "メールアドレスの認証が完了していません"
            }
        } catch{
            Logger.auth.error("ログインエラー: \(String(describing: error))")
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
    
    func forgotPassword() async {
        guard !email.isEmpty else {
            message = "メールアドレスを入力してください"
            return
        }

        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await authService.resetPassword(email: email)
            message = "パスワード再設定メールを送信しました"
        } catch {
            Logger.auth.error("パスワード再設定エラー: \(String(describing: error))")
            if let authError = error as NSError?, authError.code == 17008 {
                message = "メールアドレスの形式が正しくありません"
            } else {
                // ユーザー不在でもメール有無を秘匿するため成功扱い
                message = "パスワード再設定メールを送信しました"
            }
        }
    }

    /// パスワード変更。成功ならnil、失敗ならユーザー向けエラーメッセージを返す。
    func changePassword(current: String, new: String, confirm: String) async -> String? {
        guard !current.isEmpty, !new.isEmpty, !confirm.isEmpty else {
            return "すべての項目を入力してください"
        }
        guard new == confirm else {
            return "新しいパスワードが一致しません"
        }
        guard new.count >= 6 else {
            return "新しいパスワードは6文字以上で入力してください"
        }
        guard new != current else {
            return "現在のパスワードと異なるものを入力してください"
        }

        guard !isProcessing else { return nil }
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await authService.updatePassword(currentPassword: current, newPassword: new)
            return nil
        } catch {
            Logger.auth.error("パスワード変更失敗: \(String(describing: error))")
            switch (error as NSError).code {
            case 17004, 17009, 17011: // 認証情報不正 / ユーザー不在 / パスワード違い
                return "現在のパスワードが正しくありません"
            case 17026: // ERROR_WEAK_PASSWORD
                return "新しいパスワードが弱すぎます"
            case 17020: // ERROR_NETWORK_REQUEST_FAILED
                return "通信に失敗しました。接続を確認してもう一度お試しください。"
            default:
                return "パスワードの変更に失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    func deleteAccount(password: String) async {
        deleteErrorMessage = nil
        guard !password.isEmpty else {
            deleteErrorMessage = "パスワードを入力してください"
            return
        }

        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await authService.deleteUser(password: password)
            self.user = nil
            self.authStatus = .none
            clearFields()
        } catch {
            Logger.auth.error("アカウント削除失敗: \(String(describing: error))")
            switch (error as NSError).code {
            case 17004, 17009, 17011: // 認証情報不正 / ユーザー不在 / パスワード違い
                deleteErrorMessage = "パスワードが正しくありません"
            case 17020: // ERROR_NETWORK_REQUEST_FAILED
                deleteErrorMessage = "通信に失敗しました。接続を確認してもう一度お試しください。"
            default:
                deleteErrorMessage = "アカウントの削除に失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    
    func signOut() {
        do{
            try authService.signOut()
            self.user = nil
            self.authStatus = .none
            clearFields()
        } catch{
            Logger.auth.error("ログアウトエラー: \(String(describing: error))")
        }
    }
    
    // メール認証状態を再チェック
    func checkEmailVerification() async {
        do {
            try await authService.reloadUser()
            applyAuthState(authService.currentUser)
        } catch {
            Logger.auth.error("ユーザー情報の更新エラー: \(String(describing: error))")
        }
    }
    
    // 認証メールの再送信
    func resendVerificationEmail() async {
        do {
            try await authService.sendEmailVerification()
        } catch {
            Logger.auth.error("メール再送信エラー: \(String(describing: error))")
        }
    }
}
