import Foundation
import WeatherKit
import CoreLocation

class WeatherViewModel : NSObject , ObservableObject , CLLocationManagerDelegate{
    private var locationManager = CLLocationManager()
    private let weatherService = WeatherService()
    private let geocoder = CLGeocoder()
    @Published var currentAddress : String = "取得中..."
    @Published var currentTemperature: String = "取得中..."
    @Published var currentHumidity: String = "取得中..."
    @Published var currentCondition: String = "取得中..."
    @Published var hourlyForecasts: [HourWeather] = []
    @Published var dailyForecasts: [DayWeather] = []
    
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied:
            print("⚠️ 位置情報が拒否されています。設定アプリから許可してください。")
        case .notDetermined:
            print("🕓 まだ選択されていません")
        case .restricted:
            print("🚫 制限されています（スクリーンタイムやペアレンタルコントロールの可能性）")
        @unknown default:
            print("❓ 未知の状態")
        }
    }
    
    func requestLocationAndUpdate() {
        locationManager.requestLocation()
    }
    
    func loadAllWeather(for location: CLLocation) async {
        do{
            let current = try await weatherService.weather(for: location, including: .current)
            let hourly = try await weatherService.weather(for: location, including: .hourly)
            let daily = try await weatherService.weather(for: location, including: .daily)
            
            await MainActor.run {
                self.currentTemperature = "\(String(current.temperature.value).prefix(4))℃"
                self.currentHumidity = "\(Int(current.humidity * 100))%"
                self.currentCondition =  current.condition.description
                self.hourlyForecasts = Array(hourly.forecast.prefix(24))  //最大48時間
                self.dailyForecasts = Array(daily.forecast.prefix(7)) //最大10日
            }
        }catch{
            print("現在地の天気情報取得失敗")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation] ){
        if let location = locations.last{
            print("📍 現在地: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            Task{
                await loadAllWeather(for: location)
            }
            showPref(for: location)
        }
    }
    
    func showPref(for location : CLLocation){
        geocoder.reverseGeocodeLocation(location,preferredLocale: .init(identifier: "ja_JP")){ [weak self] placemarks,error in
            guard let self = self else { return }
            if let firstPlacemark = placemarks?.first{
                let pref = firstPlacemark.administrativeArea ?? ""
                let area = firstPlacemark.subAdministrativeArea ?? ""
                let town = firstPlacemark.locality ?? firstPlacemark.subLocality ?? ""
                self.currentAddress =  pref + area + town
            }
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 位置情報エラー: \(error)")
    }
    
}
