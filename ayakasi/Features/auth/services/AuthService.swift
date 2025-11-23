import Foundation
import FirebaseAuth

class AuthService{
    //✅
    static let shared = AuthService()
    
    //✅
    private init() {}
        
    //✅ 現在ログイン中のユーザー
    var currentUser : User? {
        return Auth.auth().currentUser
    }
    
    //✅ ログイン状態の確認
    var isLogin : Bool {
        return currentUser != nil
    }
    
    //✅ メール認証状態の確認
    var isEmailVerified: Bool {
        return currentUser?.isEmailVerified ?? false
    }
    
    //✅ 新規登録（メール確認付き）
    func signUpWithEmailVerification(email:String,password:String) async throws -> User{
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
        return result.user
    }
    
    //✅ ログイン
    func signIn(email:String,password:String) async throws -> User{
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    //✅ ログアウト
    func signOut() throws{
        try Auth.auth().signOut()
    }
    
    // 認証状態の監視
    func observeAuthState(completion: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { _, user in
            completion(user)
        }
    }
    
    // パスワードリセットメール送信
    func resetPassword(email:String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // メール認証の再送信
    func sendEmailVerification() async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.sendEmailVerification()
    }
    
    // メールアドレスの変更
    func updateEmail(newEmail: String) async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
    
    // ユーザー情報の再読み込み
    func reloadUser() async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.reload()
    }
    
    // パスワードの変更
    func updatePassword(newPassword: String) async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.updatePassword(to: newPassword)
    }
    
    // アカウント削除
    func deleteUser() async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.delete()
    }
    
    
    enum AuthError: Error {
        case noUser
    }

    
}
