import SwiftUI

struct FavoriteYokaiView: View {
    @EnvironmentObject var favoriteService: FavoriteService
    @State private var selectedYokai: Ayakasi? = nil
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var columns: [GridItem] { NeoCardItem.gridColumns(sizeClass) }

    var favoriteYokais: [Ayakasi] {
        let favoriteIds = Set(favoriteService.favoriteYokaiIds)
        return ayakasis.filter { favoriteIds.contains($0.documentId) }
    }

    private var recommended: [Ayakasi] {
        YokaiCategories.popularYokai
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
            NeoDetail(yokai: yokai, source: "bookmark")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                WaitingKozou()
                    .accessibilityHidden(true)

                Text("ブックマークはまだありません")
                    .appFont(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                Text("気になる妖怪を保存して、いつでも見返せます。\nまずは人気の妖怪からどうぞ。")
                    .appFont(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 36)
            .padding(.horizontal, 24)

            if !recommended.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("人気の妖怪")
                        .appFont(.footnote, weight: .semibold)
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

private struct WaitingKozou: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let side: CGFloat = 136
    // Eye center in the square illustration, measured from its top-left corner.
    private let eye = UnitPoint(x: 0.506, y: 0.414)

    private var illustration: some View {
        Image("bookmark-kozou")
            .resizable()
            .frame(width: side, height: side)
    }

    var body: some View {
        if reduceMotion {
            illustration
        } else {
            illustration.keyframeAnimator(initialValue: 0.0, repeating: true) { image, glance in
                image
                    .overlay {
                        image
                            .rotationEffect(.degrees(-54 * glance), anchor: eye)
                            .mask {
                                RadialGradient(
                                    colors: [.white, .clear],
                                    center: eye,
                                    startRadius: side * 0.166,
                                    endRadius: side * 0.19
                                )
                            }
                    }
                    .scaleEffect(x: 1, y: 1 + 0.014 * glance, anchor: .bottom)
            } keyframes: { _ in
                LinearKeyframe(0, duration: 1.6)
                CubicKeyframe(1, duration: 0.45)
                LinearKeyframe(1, duration: 0.85)
                CubicKeyframe(0, duration: 0.65)
                LinearKeyframe(0, duration: 1.0)
            }
        }
    }
}
