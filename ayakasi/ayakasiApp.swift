import SwiftUI
import Firebase

@main
struct ayakasiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var AuthVM: AuthViewModel
    @StateObject private var CommentVM: CommentService
    @StateObject private var FavoriteVM: FavoriteService
    @AppStorage("isDarkMode") private var isDarkMode = false

    init(){
        FirebaseApp.configure()

        _AuthVM = StateObject(wrappedValue: AuthViewModel())
        _CommentVM = StateObject(wrappedValue: CommentService(authService: AuthService.shared))
        _FavoriteVM = StateObject(wrappedValue: FavoriteService.shared)
    }
    var body: some Scene {
        WindowGroup {
            Container()
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .environmentObject(AuthVM)
                .environmentObject(CommentVM)
                .environmentObject(FavoriteVM)
                .environmentObject(DeepLinkRouter.shared)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .task { await YokaiStore.shared.refresh() }
        }
    }
}
