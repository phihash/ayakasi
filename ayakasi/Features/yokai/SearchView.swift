import SwiftUI

struct SearchView: View {
    let categories = YokaiCategories.searchCategories
    @State private var searchText = ""
    @State private var navigationPath = NavigationPath()
    @FocusState private var isSearchFocused: Bool
    func filteredYokais(for category: String) -> [Ayakasi] {
        let categoryFiltered = ayakasis.filter { $0.categories.contains(category) }

        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { ayakasi in
                ayakasi.name.contains(searchText) ||
                (ayakasi.searchKeywords?.contains(where: { $0.contains(searchText) }) ?? false)
            }
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0){
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.appTextSecondary)
                        TextField("キーワード検索", text: $searchText)
                            .focused($isSearchFocused)
                    }
                    .padding(10)
                    .background(Color.appTextFieldBackground)
                    .cornerRadius(10)
                    .padding(.bottom,12)

                    if isSearchFocused {
                        Button("閉じる") {
                            isSearchFocused = false
                        }
                        .padding(.bottom, 12)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .background(Color.appBackground)
                .onChange(of: isSearchFocused) { _, focused in
                    if !focused && !searchText.isEmpty {
                        Analytics.trackSearch(keyword: searchText)
                    }
                }

                ScrollView{
                    let allResults = categories.flatMap { filteredYokais(for: $0) }

                    if !searchText.isEmpty && allResults.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.appTextSecondary)

                            Text("「\(searchText)」はヒットしませんでした")
                                .font(.headline)
                                .foregroundColor(.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
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
                                let yokais = filteredYokais(for: category)
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
                        .padding(.bottom, 8)
                    }
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
