import SwiftUI

struct SearchView: View {
    let categories = YokaiCategories.searchCategories
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0){
                ScrollView{
                    VStack(spacing: 16) {
                        CardUI(
                            imageURL: ayakasis.first(where: { $0.imageName != "NoImage" })?.imageName,
                            title: "すべての妖怪",
                            description: "\(ayakasis.count)体の妖怪",
                            action: {
                                Analytics.trackCategorySelected(category: "すべて")
                                navigationPath.append("すべて")
                            }
                        )
                        ForEach(categories, id: \.self) { category in
                            let yokais = ayakasis.filter { $0.categories.contains(category) }
                            if !yokais.isEmpty {
                                let representativeImage = yokais.first(where: { $0.imageName != "NoImage" })?.imageName
                                CardUI(
                                    imageURL: representativeImage,
                                    title: category,
                                    description: "\(yokais.count)体の妖怪",
                                    action: {
                                        Analytics.trackCategorySelected(category: category)
                                        navigationPath.append(category)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                .background(Color.appBackground)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { category in
                AllYokaiListView(selectedCategory: category)
            }
        }
    }
}
