#if DEBUG
import SwiftUI
import PhotosUI

struct SpotVisitSection: View {
    let yokaiId: String
    let spots: [YokaiSpot]
    var filterByPlace = false
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var logs: [SpotLog] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var reload = 0
    @Binding var composer: VisitComposerContext?

    private var visits: [SpotLog] {
        logs.filter { log in
            log.yokaiId == yokaiId && (!filterByPlace || spots.contains {
                $0.spotName == log.spotName && $0.prefecture == log.prefecture
            })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("みんなの訪問記")
                .appFont(.headline, weight: .semibold)
                .accessibilityAddTraits(.isHeader)
            if let loadError {
                Text(loadError)
                    .appFont(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                Button("もう一度読み込む") { reload += 1 }
                    .appFont(.subheadline)
            } else if isLoading && visits.isEmpty {
                ProgressView("訪問記を読み込み中")
                    .appFont(.subheadline)
            } else if visits.isEmpty {
                Text("このゆかりの地の訪問記はまだありません。")
                    .appFont(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.bottom, 8)
            }
            ForEach(visits) { log in
                NavigationLink {
                    SpotLogDetailView(log: log)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline) {
                            Label(log.spotName, systemImage: "mappin.and.ellipse")
                                .appFont(.subheadline, weight: .medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .appFont(.caption)
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(Color.appTextSecondary)
                        HStack(alignment: .top, spacing: 12) {
                            if !log.body.isEmpty {
                                Text(log.body)
                                    .appFont(.body)
                                    .lineLimit(3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if let url = log.photoURLs.first {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Image(systemName: "photo").foregroundStyle(Color.appTextSecondary)
                                }
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(alignment: .bottomTrailing) {
                                        if log.photoCount > 1 {
                                            Text("\(log.photoCount)枚").appFont(.caption2)
                                                .padding(3).background(Color.appCardBackground, in: Capsule())
                                        }
                                    }
                                    .accessibilityLabel("写真\(log.photoCount)枚")
                            }
                        }
                        Text("\(log.byline)　\(log.createdAt.formatted(.relative(presentation: .numeric)))")
                            .appFont(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .multilineTextAlignment(.leading)
                    .padding(14)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(Color.appTextPrimary)
        .task(id: reload) {
            isLoading = true
            loadError = nil
            do {
                let fetched = try await SpotLogAPI.list(yokaiId: yokaiId, spot: filterByPlace ? spots.first : nil)
                try Task.checkCancellation()
                logs = fetched
            } catch {
                guard !Task.isCancelled else { return }
                loadError = error.localizedDescription
            }
            isLoading = false
        }
        // 通知で受けるのは、投稿ボタン(FAB)が画面側にあり、この一覧を直接さわれないため
        .onReceive(NotificationCenter.default.publisher(for: .spotLogPublished)) { note in
            guard let saved = note.object as? SpotLog else { return }
            logs.removeAll { $0.id == saved.id }
            logs.insert(saved, at: 0)
        }
        .onChange(of: authVM.authStatus) {
            logs = []
            reload += 1
        }
    }
}
#endif
