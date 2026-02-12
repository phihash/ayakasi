import SwiftUI
import Firebase

@main
struct ayakasiApp: App {
    @StateObject private var AuthVM = AuthViewModel()
    @StateObject private var VoteVM = VoteService()
    @StateObject private var CommentVM = CommentService()
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
