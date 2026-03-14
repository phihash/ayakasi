import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let steps = UserDefaults(suiteName: "group.net.phihash.ayakasi")?.integer(forKey: "steps") ?? 0
        return SimpleEntry(date: Date(),steps: steps)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let steps = UserDefaults(suiteName: "group.net.phihash.ayakasi")?.integer(forKey: "steps") ?? 0
        let entry = SimpleEntry(date: Date(),steps: steps)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let now = Date()
        let steps = UserDefaults(suiteName: "group.net.phihash.ayakasi")?.integer(forKey: "steps") ?? 0
        let entry = SimpleEntry(date: now, steps: steps)
        
        let cal = Calendar.current
        let minute = cal.component(.minute, from: now)
        let toAdd = 30 - (minute % 30)                  // 次の30分境界まで
        var next = cal.date(byAdding: .minute, value: toAdd, to: now)!
        next = cal.date(bySetting: .second, value: 0, of: next)! // 秒を0に
        
        // 深夜リセット（集中回避で+2〜5分にズラす）
        let nextMidnight = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 2, second: 0),
            matchingPolicy: .nextTime
        )
        
        let refreshAt = min(next, nextMidnight ?? next)
        completion(Timeline(entries: [entry], policy: .after(refreshAt)))
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let steps : Int
}

struct AyakasiWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        if family == .systemMedium {
            VStack(spacing: 8){
                Text("今日の歩数")
                    .foregroundStyle(Color.appTextBlack.opacity(0.7))
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text("\(entry.steps)歩")
                
                HStack{
                    Image("kozou")
                        .resizable()
                        .scaledToFit()
                    Image("oniicon")
                        .resizable()
                        .scaledToFit()
                    Image("warasiicon")
                        .resizable()
                        .scaledToFit()
                    Image("kappaicon")
                        .resizable()
                        .scaledToFit()
                    Image("yukiicon")
                        .resizable()
                        .scaledToFit()
                }
                
            }
        }
        
        
    }
}

struct AyakasiWidget: Widget {
    let kind: String = "AyakasiWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AyakasiWidgetEntryView(entry: entry)
                    .containerBackground(   Color.appAccent.opacity(0.2), for: .widget)
            } else {
                AyakasiWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("妖怪図鑑Widget")
        .description("これは妖怪図鑑のウィジェットです")
        .supportedFamilies([.systemMedium,.accessoryCircular,
                            .accessoryInline,
                            .accessoryRectangular,])
    }
}

