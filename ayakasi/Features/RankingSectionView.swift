import SwiftUI

struct RankingSectionView: View {
    let rankedYokai: [Ayakasi]
    @Binding var selectedYokai: Ayakasi?
    var onShowAll: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("ランキング")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                if let onShowAll {
                    Button {
                        onShowAll()
                    } label: {
                        HStack(spacing: 4) {
                            Text("全て見る")
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(rankedYokai.prefix(9)) { ayakasi in
                        NeoCardItem(item: ayakasi)
                            .onTapGesture {
                                selectedYokai = ayakasi
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
