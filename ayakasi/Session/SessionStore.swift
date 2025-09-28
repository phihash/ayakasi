//import Foundation
//import FirebaseAuth
//import AuthenticationServices
//import CryptoKit
//import Security
//
//@MainActor
//class SessionStore : ObservableObject{
//    @Published var user: User? = Auth.auth().currentUser
//    private var currentNonce: String?
//
//    func signInWithApple(credential: ASAuthorizationAppleIDCredential, rawNonce: String) async throws {
//        guard let tokenData = credential.identityToken,
//              let idToken = String(data: tokenData, encoding: .utf8) else {
//            throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "ID token missing"])
//        }
//        let authCred = OAuthProvider.credential(withProviderID: "apple.com",
//                                                idToken: idToken,
//                                                rawNonce: rawNonce,
//                                                accessToken: "")   // ← nil ではなく空文字
//        self.user = try await Auth.auth().signIn(with: authCred).user
//    }
//
//    func startSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//    }
//
//    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
//        switch result {
//        case .success(let authResult):
//            guard let credential = authResult.credential as? ASAuthorizationAppleIDCredential else { return }
//            guard let nonce = currentNonce else { return }
//            do {
//                try await signInWithApple(credential: credential, rawNonce: nonce)
//            } catch {
//                print("Firebase Apple sign-in failed: \(error)")
//            }
//        case .failure(let error):
//            print("Apple sign-in failed: \(error)")
//        }
//    }
//
//    // MARK: - Nonce helpers
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashed = SHA256.hash(data: inputData)
//        return hashed.compactMap { String(format: "%02x", $0) }.joined()
//    }
//
//    private func randomNonceString(length: Int = 32) -> String {
//        precondition(length > 0)
//        let charset: [Character] =
//          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//        var result = ""
//        var remainingLength = length
//
//        while remainingLength > 0 {
//            var randoms = [UInt8](repeating: 0, count: 16)
//            let errorCode = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
//            if errorCode != errSecSuccess { fatalError("Unable to generate nonce. SecRandomCopyBytes failed.") }
//            randoms.forEach { random in
//                if remainingLength == 0 { return }
//                if random < charset.count {
//                    result.append(charset[Int(random)])
//                    remainingLength -= 1
//                }
//            }
//        }
//        return result
//    }
//}
