import WidgetKit
import SwiftUI
import UIKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> YokaiEntry {
        YokaiEntry(date: Date(), yokai: Self.yokai(for: Date()), imageData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (YokaiEntry) -> ()) {
        completion(YokaiEntry(date: Date(), yokai: Self.yokai(for: Date()), imageData: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<YokaiEntry>) -> ()) {
        let now = Date()
        let yokai = Self.yokai(for: now)

        // 深夜リセットで翌日の妖怪へ（集中回避で0:02にズラす）
        let cal = Calendar.current
        let refreshAt = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 2, second: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(6 * 3600)

        fetchImage(from: yokai.imageName) { data in
            let entry = YokaiEntry(date: now, yokai: yokai, imageData: data)
            completion(Timeline(entries: [entry], policy: .after(refreshAt)))
        }
    }

    // 日付で決まる「今日の妖怪」（0時に切り替わる）
    static func yokai(for date: Date) -> Ayakasi {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return ayakasis[day % ayakasis.count]
    }

    private func fetchImage(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            completion(data)
        }.resume()
    }
}

struct YokaiEntry: TimelineEntry {
    let date: Date
    let yokai: Ayakasi
    let imageData: Data?
}

struct AyakasiWidgetEntryView : View {
    var entry: YokaiEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                medium
            case .accessoryInline:
                Text("今日の妖怪：\(entry.yokai.name)")
            case .accessoryRectangular:
                rectangular
            default:
                small
            }
        }
        // タップで該当妖怪の詳細へディープリンク
        .widgetURL(URL(string: "ayakasi://yokai/\(entry.yokai.documentId)"))
    }

    private var small: some View {
        VStack(spacing: 6) {
            yokaiImage
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(entry.yokai.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var medium: some View {
        HStack(spacing: 12) {
            yokaiImage
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text("今日の妖怪")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.yokai.name)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(entry.yokai.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("今日の妖怪")
                .font(.caption2)
            Text(entry.yokai.name)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var yokaiImage: Image {
        if let data = entry.imageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return Image("youkaiicon") // 通信失敗時は同梱アイコンにフォールバック
    }
}

struct AyakasiWidget: Widget {
    let kind: String = "AyakasiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AyakasiWidgetEntryView(entry: entry)
                    .containerBackground(Color.purple.opacity(0.2), for: .widget)
            } else {
                AyakasiWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("今日の妖怪")
        .description("毎日ひとり、妖怪を紹介します")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryInline,
                            .accessoryRectangular])
    }
}
