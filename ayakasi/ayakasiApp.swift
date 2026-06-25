import SwiftUI
import Firebase

@main
struct ayakasiApp: App {
    @StateObject private var AuthVM: AuthViewModel
    @StateObject private var BlockingVM: UserBlockingService
    @StateObject private var ReportVM: CommentReportService
    @StateObject private var CommentVM: CommentService
    @StateObject private var FavoriteVM: FavoriteService
    @AppStorage("isDarkMode") private var isDarkMode = false

    init(){
        FirebaseApp.configure()

        let authService = AuthService.shared
        let blockingService = UserBlockingService(authService: authService)

        _AuthVM = StateObject(wrappedValue: AuthViewModel())
        _BlockingVM = StateObject(wrappedValue: blockingService)
        _ReportVM = StateObject(wrappedValue: CommentReportService(authService: authService))
        _CommentVM = StateObject(wrappedValue: CommentService(
            authService: authService,
            tokenBucket: TokenBucket(maxToken: 5, refillInterval: 480, storageKeyPrefix: "comment"),
            blockingService: blockingService
        ))
        _FavoriteVM = StateObject(wrappedValue: FavoriteService.shared)
    }
    var body: some Scene {
        WindowGroup {
            Container()
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .environmentObject(AuthVM)
                .environmentObject(CommentVM)
                .environmentObject(BlockingVM)
                .environmentObject(ReportVM)
                .environmentObject(FavoriteVM)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
