import SwiftUI
import HealthKit
import WidgetKit

struct Walk: View {
    @State private var steps = 0
    @State private var activeKcal : Double = 0
    @State private var basalKcal : Double = 0
    private let healthStore = HKHealthStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var isFetching = false
    let screenWidth = UIScreen.main.bounds.width
    
    func fetchSteps() async {
        // HealthCareを利用できるか?利用できなければreturnそこで終了
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        guard let activeType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned), let basalType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else { return }
        //許可　読み取りだけ
        
        try? await healthStore.requestAuthorization(toShare: [], read: [stepType,activeType,basalType])
        
        //その日の0時から
        let startOfDay = Calendar.current.startOfDay(for: Date())
        // その日の0時からnow!まで
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate ,
            options: .cumulativeSum
        ){ _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            DispatchQueue.main.async {
                self.steps = Int(value)
                UserDefaults(suiteName: "group.net.phihash.ayakasi")?.set(Int(value), forKey: "steps")
                WidgetCenter.shared.reloadTimelines(ofKind: "AyakasiWidget")
            }
        }
        
        let query1 = HKStatisticsQuery(
            quantityType: activeType,
            quantitySamplePredicate: predicate ,
            options: .cumulativeSum
        ){ _, result, _ in
            
            DispatchQueue.main.async {
                self.activeKcal = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            }
        }
        
        let query2 = HKStatisticsQuery(
            quantityType: basalType,
            quantitySamplePredicate: predicate ,
            options: .cumulativeSum
        ){ _, result, _ in
            
            DispatchQueue.main.async {
                self.basalKcal = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            }
        }
        
        healthStore.execute(query)
        healthStore.execute(query1)
        healthStore.execute(query2)
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                
                VStack(spacing: 12){
                   
                    HStack(spacing:12){
                        VStack(spacing: 8){
                            Text("歩いた歩数")
                            Text("\(steps)歩")
                                .font(Font.custom("NotoSansJP-VariableFont_wght.ttf", size: 28))
                                .fontWeight(.bold)
                        }
                        VStack(spacing: 8){
                            Text("アクティブ消費")
                            Text("\(activeKcal, specifier: "%.0f") kcal")
                                .font(Font.custom("NotoSansJP-VariableFont_wght.ttf", size: 28))
                                .fontWeight(.bold)
                        }
                        VStack(spacing: 8){
                            Text("基礎代謝")
                            Text("\(basalKcal,  specifier: "%.0f") kcal")
                                .font(Font.custom("NotoSansJP-VariableFont_wght.ttf", size: 28))
                                .fontWeight(.bold)
                        }
                    }
                }
                
                Image("kozou")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.4)

                Text("Appleヘルスケアと連携した情報を利用しています")
                    .font(.subheadline)
            }
            .toolbar{
                ToolbarItem(placement:.navigationBarTrailing){
                    NavigationLink(destination: SettingView() ){
                        Image("setting")
                    }
                }
            }
            .navigationTitle("今日の活動")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear{
            Task{
                await fetchSteps()
            }
        }
        .onChange(of: scenePhase){ newPhase in
            //とってきてる、アクティブでない時はreturn
            guard newPhase == .active , !isFetching else {return}
            isFetching = true
            if newPhase == .active {
                Task {
                    await fetchSteps()
                    isFetching = false
                }
            }
        }
    }
}

