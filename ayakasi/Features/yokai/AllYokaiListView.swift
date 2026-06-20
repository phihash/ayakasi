import SwiftUI

struct AllYokaiListView: View {
    let categories = YokaiCategories.allCategories
    @State private var selectedYokai : Ayakasi? = nil
    let selectedCategory: String
    @Environment(\.dismiss) var dismiss

    var filteredYokai: [Ayakasi] {
        var result: [Ayakasi]
        if selectedCategory == "すべて" {
            result = ayakasis
        } else {
            result = ayakasis.filter { $0.categories.contains(selectedCategory) }
        }
        return result
    }

    private var title: String {
        selectedCategory == "すべて" ? "すべての妖怪" : selectedCategory
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0){
                ScrollView{
                    LazyVGrid(columns: columns, spacing: 12){
                        ForEach(filteredYokai, id: \.id){ ayakasi in
                            NeoCardItem(item: ayakasi) {
                                selectedYokai = ayakasi
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)
                }
                .padding(.top, 24)
                .background(Color("Ivory"))
            }
            .fullScreenCover(item: $selectedYokai) { yokai in
                NavigationStack {
                    NeoDetail(yokai: yokai)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
