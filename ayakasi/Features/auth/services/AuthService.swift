import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
class AuthService: ObservableObject {

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
    
    enum AuthError: Error {
        case noUser
    }
    
}
