import SwiftUI
import Kingfisher

struct FavoriteYokaiView: View {
    @EnvironmentObject var favoriteService: FavoriteService
    @State private var selectedYokai: Ayakasi? = nil
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var favoriteYokais: [Ayakasi] {
        let favoriteIds = favoriteService.favoriteYokaiIds
        return ayakasis.filter { favoriteIds.contains($0.documentId) }
    }

    private let popularNames = ["豆腐小僧", "うみぼうず", "崇徳天皇", "胴面", "絹狸", "あかなめ"]

    private var recommended: [Ayakasi] {
        popularNames.compactMap { name in ayakasis.first { $0.name == name } }
    }

    var body: some View {
        ScrollView {
            if favoriteYokais.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(favoriteYokais, id: \.id) { ayakasi in
                        NeoCardItem(item: ayakasi) {
                            selectedYokai = ayakasi
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .background(Color.appBackground)
        .navigationTitle("ブックマーク")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedYokai) { yokai in
            NeoDetail(yokai: yokai)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                Image(systemName: "bookmark")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.bottom, 2)

                Text("ブックマークはまだありません")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                Text("気になる妖怪を保存して、いつでも見返せます。\nまずは人気の妖怪からどうぞ。")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 72)
            .padding(.horizontal, 24)

            if !recommended.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("人気の妖怪")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(recommended, id: \.id) { ayakasi in
                            NeoCardItem(item: ayakasi) {
                                selectedYokai = ayakasi
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.bottom, 24)
    }
}
