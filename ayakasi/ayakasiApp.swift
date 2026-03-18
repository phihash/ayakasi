import SwiftUI
import Firebase

@main
struct ayakasiApp: App {
    @StateObject private var AuthVM = AuthViewModel()
    @StateObject private var VoteVM = VoteService(
        authService: AuthService.shared,
        tokenBucket: TokenBucket(maxToken: 15, refillInterval: 300, storageKeyPrefix: "vote")
    )
    @StateObject private var BlockingVM = UserBlockingService(authService: AuthService.shared)
    @StateObject private var ReportVM = CommentReportService(authService: AuthService.shared)
    @StateObject private var CommentVM = CommentService(
        authService: AuthService.shared,
        tokenBucket: TokenBucket(maxToken: 5, refillInterval: 480, storageKeyPrefix: "comment"),
        blockingService: UserBlockingService(authService: AuthService.shared)
    )
    @StateObject private var FavoriteVM = FavoriteService.shared
    @AppStorage("isDarkMode") private var isDarkMode = false

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
                .environmentObject(BlockingVM)
                .environmentObject(ReportVM)
                .environmentObject(FavoriteVM)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
