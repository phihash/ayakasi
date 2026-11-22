import SwiftUI

struct SearchView: View {
    @State private var selectedCategory = YokaiCategories.popularLabel
    @State private var selectedYokai: Ayakasi? = nil
    @State private var selectedSource = "category"
    @EnvironmentObject private var router: DeepLinkRouter

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var columns: [GridItem] { NeoCardItem.gridColumns(sizeClass) }

    // よく見られている(デフォ・軽い) → すべて → 妖怪が1体以上いるカテゴリ
    private var availableCategories: [String] {
        [YokaiCategories.popularLabel, "すべて"] + YokaiCategories.searchCategories
    }

    private var filteredYokai: [Ayakasi] {
        if selectedCategory == YokaiCategories.popularLabel {
            return YokaiCategories.popularYokai
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
                                selectedSource = selectedCategory == YokaiCategories.popularLabel ? "popular" : "category"
                                selectedYokai = yokai
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 60)
                }

                VStack(spacing: 12) {
                    // 設定の奥にしかないと見つからないという問い合わせがあったので、最初に開くタブに置く
                    NavigationLink {
                        FavoriteYokaiView()
                    } label: {
                        ActionCircleIcon(systemName: "bookmark")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Analytics.trackScreenView(screenName: "ブックマーク一覧(さがす)")
                    })
                    .accessibilityLabel("ブックマーク一覧")

                    // キーワード検索(カテゴリに関係なく全妖怪から)
                    NavigationLink {
                        YokaiSearchView { yokai in
                            selectedSource = "search"
                            selectedYokai = yokai
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .appFont(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.appSecondary)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel("妖怪を検索")
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
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
                                .appFont(.caption2)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedYokai) { yokai in
                NeoDetail(yokai: yokai, source: selectedSource)
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
        guard let id, let yokai = yokaiById(id) else { return }
        selectedSource = "notification"
        selectedYokai = yokai
        router.pendingYokaiId = nil
    }
}

// キーワード検索画面。上の検索FABから開く。
struct YokaiSearchView: View {
    @State private var searchText = ""
    // 送信・結果タップ・画面を離れる、のどれでも計測を呼ぶので、同じ語を二重に送らないよう覚えておく
    @State private var lastTrackedKeyword = ""
    @FocusState private var isSearchFocused: Bool
    let onSelect: (Ayakasi) -> Void

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var searchResults: [Ayakasi] {
        let keyword = trimmedSearchText
        guard !keyword.isEmpty else {
            return []
        }

        return ayakasis.filter { ayakasi in
            ayakasi.name.localizedCaseInsensitiveContains(keyword) ||
            ayakasi.categories.contains(where: { $0.localizedCaseInsensitiveContains(keyword) }) ||
            (ayakasi.searchKeywords?.contains(where: { $0.localizedCaseInsensitiveContains(keyword) }) ?? false)
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
                let results = searchResults
                if trimmedSearchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.appTextSecondary)

                        Text("妖怪名、地域、読み方で検索できます")
                            .appFont(.subheadline)
                            .foregroundColor(.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else if results.isEmpty {
                    VStack(spacing: 12) {
                        FlusteredKozou()
                            .accessibilityHidden(true)

                        Text("「\(searchText)」はヒットしませんでした")
                            .appFont(.subheadline)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(results, id: \.id) { yokai in
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
        }
        .background(Color.appBackground)
        .navigationTitle("妖怪を検索")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            trackSearchIfNeeded()
        }
        .onAppear {
            // 詳細から戻ったときにキーボードで結果を隠さないよう、まだ何も打っていないときだけ
            if searchText.isEmpty {
                isSearchFocused = true
            }
        }
    }

    private func trackSearchIfNeeded() {
        if !trimmedSearchText.isEmpty, trimmedSearchText != lastTrackedKeyword {
            lastTrackedKeyword = trimmedSearchText
            Analytics.trackSearch(keyword: trimmedSearchText)
            if searchResults.isEmpty {
                Analytics.trackSearchNoResult(keyword: trimmedSearchText)
            }
        }
    }
}

private struct FlusteredKozou: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image("search-kozou")
            .resizable()
            .scaledToFit()
            .frame(width: 128, height: 128)
            .overlay(alignment: .topLeading) {
                if reduceMotion {
                    drop(size: 12, tilt: -110)
                        .offset(x: 114, y: 22)
                } else {
                    Color.clear
                        .keyframeAnimator(initialValue: 0.0, repeating: true) { layer, time in
                            layer.overlay(alignment: .topLeading) {
                                movingDrop(size: 13, tilt: -112, rise: -9, progress: time)
                                    .offset(x: 101, y: 28)
                                movingDrop(size: 9, tilt: -84, rise: 2, progress: time - 0.18)
                                    .offset(x: 105, y: 36)
                            }
                        } keyframes: { _ in
                            MoveKeyframe(0)
                            LinearKeyframe(1.18, duration: 0.46)
                            LinearKeyframe(1.18, duration: 1.7)
                        }
                }
            }
    }

    private func drop(size: CGFloat, tilt: Double) -> some View {
        Image(systemName: "drop.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color(red: 0.34, green: 0.64, blue: 0.72))
            .frame(width: size * 0.7, height: size)
            .rotationEffect(.degrees(tilt))
    }

    private func movingDrop(size: CGFloat, tilt: Double, rise: CGFloat, progress: Double) -> some View {
        let t = min(max(progress, 0), 1)
        let travel = 1 - (1 - t) * (1 - t)
        return drop(size: size, tilt: tilt)
            .scaleEffect(x: 0.7 + 0.55 * travel, y: 0.85)
            .offset(x: 24 * travel, y: rise * travel)
            .opacity(min(t / 0.12, 1, (1 - t) / 0.38))
    }
}
