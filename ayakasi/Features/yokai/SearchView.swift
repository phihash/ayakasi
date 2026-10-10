import SwiftUI

private enum SearchRoute: Hashable {
    case category(String)
    case yokai(String)   // documentId（通知タップからの deep link 用）
}

struct SearchView: View {
    let categories = YokaiCategories.searchCategories
    @State private var navigationPath: [SearchRoute] = []
    @EnvironmentObject private var router: DeepLinkRouter

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
                                navigationPath.append(.category("すべて"))
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
                                        navigationPath.append(.category(category))
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
            .navigationTitle("さがす")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(navigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case .category(let category):
                    AllYokaiListView(selectedCategory: category)
                case .yokai(let documentId):
                    if let yokai = ayakasis.first(where: { $0.documentId == documentId }) {
                        NeoDetail(yokai: yokai)
                    }
                }
            }
        }
        .onChange(of: router.pendingYokaiId) { _, id in
            consumeDeepLink(id)
        }
        .onAppear {
            // コールド起動（通知タップで起動）時の取りこぼし対策
            consumeDeepLink(router.pendingYokaiId)
        }
    }

    /// 通知タップで来た documentId を消化して該当妖怪へ遷移
    private func consumeDeepLink(_ id: String?) {
        guard let id, ayakasis.contains(where: { $0.documentId == id }) else { return }
        navigationPath = [.yokai(id)]
        router.pendingYokaiId = nil
    }
}
