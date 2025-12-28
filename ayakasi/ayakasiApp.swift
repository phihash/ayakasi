import SwiftUI
import Firebase

@main
struct ayakasiApp: App {
    @StateObject private var ColorVM = ColorViewModel()
    @StateObject private var AuthVM = AuthViewModel()
    @StateObject private var VoteVM = VoteService()
    @StateObject private var CommentVM = CommentService()
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            Container()
                .environmentObject(ColorVM)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .environmentObject(AuthVM)
                .environmentObject(VoteVM)
                .environmentObject(CommentVM)
        }
    }
}
