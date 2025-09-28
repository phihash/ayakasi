import SwiftUI

@main
struct ayakasiApp: App {
    @StateObject private var WeatherVM = WeatherViewModel()
    @StateObject private var ColorVM = ColorViewModel()
//    @StateObject private var sessionStore = SessionStore()
//    init(){
//        FirebaseApp.configure()
//    }
    var body: some Scene {
        WindowGroup {
            Container()
                .environmentObject(WeatherVM)
                .environmentObject(ColorVM)
//                .environmentObject(sessionStore)
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
