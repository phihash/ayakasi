import SwiftUI

@main
struct ayakasiApp: App {
    @StateObject private var WeatherVM = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            Container()
                .environmentObject(WeatherVM)
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
