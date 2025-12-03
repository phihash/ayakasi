import SwiftUI
import WeatherKit
import CoreLocation

struct Weather: View {
    @EnvironmentObject var currentWeatherVM: WeatherViewModel
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: Date())
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var dateFormatter : DateFormatter  {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        var cal = Calendar(identifier: .gregorian)
        cal.locale = f.locale              // ← カレンダー側のロケールも合わせる
        f.calendar = cal
        f.setLocalizedDateFormatFromTemplate("MdE") // ロケールに沿って並び/表記を決める
        return f
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 40){
                    
                    Text(currentWeatherVM.currentAddress)
                        .padding(.top,20)
                    VStack{
                        Text("天気")
                            .font(.headline)
                        Text(currentWeatherVM.currentCondition.description)
                            .font(.title2)
                    }
                    HStack (spacing: 24){
                        VStack(spacing: 8){
                            Text("気温")
                                .font(.headline)
                            Text("\(currentWeatherVM.currentTemperature)")
                                .font(.title2)
                        }
                        VStack(spacing: 8){
                            Text("湿度")
                                .font(.headline)
                            Text(currentWeatherVM.currentHumidity)
                                .font(.title2)
                        }
                    }
                    
                    HStack{
                        Text("今日の天気")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack{
                            ForEach(currentWeatherVM.hourlyForecasts.indices, id: \.self) { idx in
                                let hour = currentWeatherVM.hourlyForecasts[idx]
                                
                                VStack {
                                    Image(systemName: hour.symbolName)
                                        .font(.title)
                                        .padding(.bottom,12)
                                    Text(hour.date, style: .time)              // ← 時刻
                                    HStack{
                                        Text("\(Int(hour.temperature.value))℃")    // ← 気温
                                        Text("\(Int(hour.humidity * 100))%")    // ← 湿度
                                    }
                                    HStack{
                                        Text("UV指数: ")
                                        Text("\(Int(hour.uvIndex.value))")    // ← uvIndex
                                    }
                                }
                                .padding()
                            }
                            
                        }
                    }
                    .padding(.horizontal,12)
                    
                    VStack(spacing: 8){
                        ForEach(currentWeatherVM.dailyForecasts.indices ,id: \.self){ index in
                            let  day =  currentWeatherVM.dailyForecasts[index]
                            HStack{
                                VStack(alignment: .leading, spacing: 12){
                                    Text(day.date, formatter: dateFormatter)
                                        .font(.title2)
                                    
                                    HStack{
                                        Text("\(Int(day.highTemperature.value))℃")
                                            .font(.title3)
                                            .foregroundStyle(.red)
                                        
                                        Text("\(Int(day.lowTemperature.value))℃")
                                            .font(.title3)
                                            .foregroundStyle(.blue)
                                        
                                        Text("降水確率: \(Int(day.precipitationChance * 100))%")
                                        
                                    }
                                    
                                }
                                .fontWeight(.bold)
                                
                                
                                Spacer()
                                
                                Image(systemName: day.symbolName)
                                    .font(.largeTitle)
                            }
                            .padding(.horizontal,32)
                            .padding(.vertical,24)
                            
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.vertical,4)
                        .padding(.horizontal,12)
                    }
                    
                    
                    VStack(spacing: 12){
                        Text("Data provided by  WeatherKit")
                            .font(.caption)
                        Link(" Weather",destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                    }
                }
                .navigationTitle("現在地の情報")
                .navigationBarTitleDisplayMode(.inline)
//                .toolbar{
//                    ToolbarItem(placement:.navigationBarLeading){
//                        Text(currentDateString)
//                            .fontWeight(.bold)
//                    }
//                }
                .toolbar{
                    ToolbarItem{
                        Button("更新"){
                            currentWeatherVM.requestLocationAndUpdate()
                        }
                    }
                }
            }
        }
    }
}

