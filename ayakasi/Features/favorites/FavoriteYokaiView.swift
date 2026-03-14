import SwiftUI
import Kingfisher

struct FavoriteYokaiView: View {
    @EnvironmentObject var favoriteService: FavoriteService
    @State private var selectedYokai: Ayakasi? = nil
    let screenWidth = UIScreen.main.bounds.width
    let itemSpacing: CGFloat = 30

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
                let columns = Array(repeating: GridItem(.flexible(), spacing: itemSpacing), count: 3)

                LazyVGrid(columns: columns, spacing: itemSpacing) {
                    ForEach(favoriteYokais, id: \.id) { ayakasi in
                        NeoCardItem(item: ayakasi)
                            .onTapGesture {
                                selectedYokai = ayakasi
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .background(Color.appBackground)
        .navigationTitle("お気に入り")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedYokai) { yokai in
            NavigationStack {
                NeoDetail(yokai: yokai)
            }
        }
    }
}
