import SwiftUI

struct AllYokaiListView: View {
    let categories = YokaiCategories.allCategories
    @State private var selectedYokai: Ayakasi? = nil
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
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredYokai, id: \.id) { ayakasi in
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

            if selectedCategory == "すべて" {
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

private struct YokaiSearchView: View {
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
        }
    }
}
