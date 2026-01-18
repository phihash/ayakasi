import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    private let db = Firestore.firestore()

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
            completion(user)
        }
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

    // TODO エラー処理を考える
    func ensureUserExists() async -> Bool {
        guard let user = currentUser else { return false }

        do {
            if try await userDocumentExists(user) {
                return true
            }
            try await createUserDocument(user)
            return true
        } catch {
            print("⚠️ ensureUserExists失敗: \(error)")
            return false
        }
    }
    //ここまで
    
    enum AuthError: Error {
        case noUser
    }
}
