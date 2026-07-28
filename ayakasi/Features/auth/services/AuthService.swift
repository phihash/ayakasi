import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import os

@MainActor
protocol AuthServiceProtocol {
    var currentUser: User? { get }
}

@MainActor
class AuthService: ObservableObject , AuthServiceProtocol {
    static let shared = AuthService()
    private var db: Firestore {
        Firestore.firestore()
    }

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
    
    func updateEmail(newEmail: String) async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
    
    func reloadUser() async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.reload()
    }
    
    func updatePassword(newPassword: String) async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.updatePassword(to: newPassword)
    }
    
    func deleteUser() async throws {
        guard let user = currentUser else {
            throw AuthError.noUser
        }
        try await user.delete()
    }
    
    // ここから
    private func userDocumentExists(_ user: User) async throws -> Bool {
        let userDoc = try await db.collection("users").document(user.uid).getDocument()
        return userDoc.exists
    }

    private func createUserDocument(_ user: User) async throws {
        try await db.collection("users").document(user.uid).setData([
            "createdAt": FieldValue.serverTimestamp(),
            "blockedUsers": [],
            "favoriteYokais": [],
            "bookmarkedComments": [],
            "reportedComments": []
        ])
    }

    /// usersドキュメントの存在を保証する。起動直後のネットワーク不調に備えて1回だけリトライする。
    /// 失敗してもアプリは閲覧機能で使えるためthrowはしない（コメント系が使うときに再度呼ばれる）。
    @discardableResult
    func ensureUserExists() async -> Bool {
        guard let user = currentUser else { return false }

        for attempt in 1...2 {
            do {
                if try await userDocumentExists(user) {
                    return true
                }
                try await createUserDocument(user)
                return true
            } catch {
                Logger.auth.error("ensureUserExists失敗(\(attempt)回目): \(String(describing: error))")
                if attempt == 1 {
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒後に再試行
                }
            }
        }
        return false
    }
    //ここまで
    
    enum AuthError: Error {
        case noUser
    }
}
