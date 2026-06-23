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

    var body: some View {
        ScrollView {
            if favoriteYokais.isEmpty {
                VStack(spacing: 16) {

                    Text("お気に入りに追加した妖怪はありません")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.appTextSecondary)
         
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
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
        .navigationTitle("お気に入り")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedYokai) { yokai in
            NeoDetail(yokai: yokai)
        }
    }
}
