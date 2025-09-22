import SwiftUI

@main
struct ayakasiApp: App {
    @StateObject private var WeatherVM = WeatherViewModel()
    @StateObject private var ColorVM = ColorViewModel()
    var body: some Scene {
        WindowGroup {
            Container()
                .environmentObject(WeatherVM)
                .environmentObject(ColorVM)
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
