import SwiftUI

struct SearchView: View {
    @State private var selectedCategory = YokaiCategories.popularLabel
    @State private var selectedYokai: Ayakasi? = nil
    @EnvironmentObject private var router: DeepLinkRouter

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // よく見られている(デフォ・軽い) → すべて → 妖怪が1体以上いるカテゴリだけ
    private var availableCategories: [String] {
        [YokaiCategories.popularLabel, "すべて"] + YokaiCategories.searchCategories.filter { category in
            ayakasis.contains { $0.categories.contains(category) }
        }
    }

    private var filteredYokai: [Ayakasi] {
        if selectedCategory == YokaiCategories.popularLabel {
            return YokaiCategories.popularNames.compactMap { name in ayakasis.first { $0.name == name } }
        } else if selectedCategory == "すべて" {
            return ayakasis
        } else {
            return ayakasis.filter { $0.categories.contains(selectedCategory) }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredYokai, id: \.id) { yokai in
                            NeoCardItem(item: yokai) {
                                selectedYokai = yokai
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 60)
                }
                .background(Color("Ivory"))

                // キーワード検索(カテゴリに関係なく全妖怪から)
                NavigationLink {
                    YokaiSearchView { yokai in
                        selectedYokai = yokai
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("妖怪を検索")
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .navigationTitle("さがす")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("カテゴリ", selection: $selectedCategory) {
                            ForEach(availableCategories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedCategory)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedYokai) { yokai in
                NeoDetail(yokai: yokai)
            }
        }
        .onChange(of: selectedCategory) { _, newValue in
            Analytics.trackCategorySelected(category: newValue)
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
        guard let id, let yokai = ayakasis.first(where: { $0.documentId == id }) else { return }
        selectedYokai = yokai
        router.pendingYokaiId = nil
    }
}

// キーワード検索画面。上の検索FABから開く。
struct YokaiSearchView: View {
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    let onSelect: (Ayakasi) -> Void

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var searchResults: [Ayakasi] {
        guard !trimmedSearchText.isEmpty else {
            return []
        }

        return ayakasis.filter { ayakasi in
            ayakasi.name.localizedCaseInsensitiveContains(trimmedSearchText) ||
            ayakasi.categories.contains(where: { $0.localizedCaseInsensitiveContains(trimmedSearchText) }) ||
            (ayakasi.searchKeywords?.contains(where: { $0.localizedCaseInsensitiveContains(trimmedSearchText) }) ?? false)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appTextSecondary)

                TextField("キーワード検索", text: $searchText)
                    .focused($isSearchFocused)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit {
                        trackSearchIfNeeded()
                    }
            }
            .padding(12)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            ScrollView {
                if trimmedSearchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.appTextSecondary)

                        Text("妖怪名、地域、読み方で検索できます")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else if searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.appTextSecondary)

                        Text("「\(searchText)」はヒットしませんでした")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(searchResults, id: \.id) { yokai in
                            YokaiSearchResultItem(yokai: yokai) {
                                trackSearchIfNeeded()
                                onSelect(yokai)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
            }
            .background(Color("Ivory"))
        }
        .background(Color("Ivory"))
        .navigationTitle("妖怪を検索")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            trackSearchIfNeeded()
        }
        .onAppear {
            isSearchFocused = true
        }
    }

    private func trackSearchIfNeeded() {
        if !trimmedSearchText.isEmpty {
            Analytics.trackSearch(keyword: trimmedSearchText)
            if searchResults.isEmpty {
                Analytics.trackSearchNoResult(keyword: trimmedSearchText)
            }
        }
    }
}
