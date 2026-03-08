import SwiftUI
import Firebase

@main
struct ayakasiApp: App {
    @StateObject private var AuthVM = AuthViewModel()
    @StateObject private var VoteVM = VoteService(
        authService: AuthService.shared,
        tokenBucket: TokenBucket(maxToken: 15, refillInterval: 300, storageKeyPrefix: "vote")
    )
    @StateObject private var CommentVM = CommentService(
        authService: AuthService.shared,
        tokenBucket: TokenBucket(maxToken: 5, refillInterval: 480, storageKeyPrefix: "comment")   
    )
    @StateObject private var FavoriteVM = FavoriteService.shared
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            Container()
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .environmentObject(AuthVM)
                .environmentObject(VoteVM)
                .environmentObject(CommentVM)
                .environmentObject(FavoriteVM)
        }
    }
}
