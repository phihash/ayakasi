import SwiftUI
import Firebase

@main
struct ayakasiApp: App {
    @StateObject private var WeatherVM = WeatherViewModel()
    @StateObject private var ColorVM = ColorViewModel()
    @StateObject private var AuthVM = AuthViewModel()
    @StateObject private var VoteVM = VoteService()
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            
            Container()
                .environmentObject(WeatherVM)
                .environmentObject(ColorVM)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .environmentObject(AuthVM)
                .environmentObject(VoteVM)
          
        }
    }
}
