import Foundation
import FirebaseAuth
import SwiftUI
import os

@MainActor
protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func authorizedRequest(_ url: URL, forceRefresh: Bool) async throws -> URLRequest
}

@MainActor
class AuthService: ObservableObject , AuthServiceProtocol {
    static let shared = AuthService()
    private init() {}
        
    var currentUser : User? {
        return Auth.auth().currentUser
    }
    
    var isEmailVerified: Bool {
        return currentUser?.isEmailVerified ?? false
    }
    
    func signUpWithEmailVerification(email:String,password:String) async throws -> User{
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
        return result.user
    }
    
    func signIn(email:String,password:String) async throws -> User{
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
    
    func observeAuthState(completion: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in
                completion(user)
            }
        }
    }

    nonisolated func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    func resetPassword(email:String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func sendEmailVerification() async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.sendEmailVerification()
    }
    
    /// Worker(D1)の本人確認つきAPI用。Firebase の ID トークンを Authorization に付けたリクエストを作る。
    /// forceRefresh: false でも期限が近ければ自動で更新されたトークンが返るので、ここで期限は気にしない
    func authorizedRequest(_ url: URL, forceRefresh: Bool = false) async throws -> URLRequest {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(try await user.getIDToken(forcingRefresh: forceRefresh))", forHTTPHeaderField: "Authorization")
        return request
    }

    func reloadUser() async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.reload()
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = currentUser, let email = user.email else {
            throw AuthError.noUser
        }
        // 重要操作なので変更直前に現在のパスワードで再認証（Firebaseの17014回避）
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        try await user.reauthenticate(with: credential)
        try await user.updatePassword(to: newPassword)
    }
    
    func deleteUser(password: String) async throws {
        guard let user = currentUser, let email = user.email else {
            throw AuthError.noUser
        }
        // 重要操作なので削除直前に再認証（Firebaseの17014回避）
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
        try await user.delete()
    }
    
    
    enum AuthError: Error {
        case noUser
    }
}
