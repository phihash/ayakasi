#if DEBUG
import SwiftUI

struct SpotDetailView: View {
    let spot: YokaiSpot
    @State private var composer: VisitComposerContext?
    @State private var logYokaiId: String?
    @State private var selectedYokai: Ayakasi?

    private var relatedYokais: [Ayakasi] { spot.yokaiIds.compactMap(yokaiById) }
    private var owners: [Ayakasi] {
        ayakasis.filter { yokai in
            yokai.relatedSpots?.contains { $0.spotName == spot.spotName && $0.prefecture == spot.prefecture } == true
        }
    }
    private var owner: Ayakasi? { owners.first { $0.documentId == logYokaiId } ?? owners.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let description = spot.description {
                    Text(description)
                        .lineSpacing(6)
                        .foregroundStyle(Color.appTextPrimary)
                }
                if !relatedYokais.isEmpty { yokaiRow }
                if let owner {
                    if owners.count > 1 {
                        Picker("訪問記の妖怪", selection: Binding(get: { owner.documentId }, set: { logYokaiId = $0 })) {
                            ForEach(owners) { Text($0.name).tag($0.documentId) }
                        }
                    }
                    SpotVisitSection(yokaiId: owner.documentId, spots: [spot], filterByPlace: true, composer: $composer)
                        .id(owner.documentId)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .background(Color.appBackground)
        .overlay(alignment: .bottomTrailing) {
            if let owner {
                VisitComposeButton(yokaiId: owner.documentId, spots: [spot], composer: $composer)
                    .padding(.trailing, 22)
                    .padding(.bottom, 14)
            }
        }
        .visitComposer($composer)
        .onChange(of: logYokaiId) { composer = nil }
        .navigationTitle("ゆかりの地")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $selectedYokai) { yokai in
            NeoDetail(yokai: yokai, source: "spot")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            SegmentTag(left: "ゆかりの地", right: spot.prefecture)
            Text(spot.spotName)
                .appFont(.title2, weight: .bold)
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    private var yokaiRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(relatedYokais) { yokai in
                    Button { selectedYokai = yokai } label: {
                        HStack(spacing: 8) {
                            YokaiThumbnail(yokai: yokai, size: 36)
                            Text(yokai.name)
                                .appFont(.subheadline, weight: .semibold)
                                .foregroundStyle(Color.appTextPrimary)
                            Image(systemName: "chevron.right")
                                .appFont(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(6)
                        .padding(.trailing, 6)
                        .background(Capsule().fill(Color.appCardBackground))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// 「食べる｜スイーツ」のような左が塗り・右が枠の2つ組タグ
struct SegmentTag: View {
    let left: String
    let right: String

    var body: some View {
        HStack(spacing: 0) {
            Text(left)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appSecondary)
            Text(right)
                .foregroundStyle(Color.appSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .appFont(.caption, weight: .semibold)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.appSecondary, lineWidth: 1))
    }
}

struct SpotLogDetailView: View {
    let log: SpotLog

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Label("\(log.spotName)（\(log.prefecture)）", systemImage: "mappin.and.ellipse")
                    .appFont(.headline)
                Text("\(log.byline)　\(log.createdAt.formatted(.relative(presentation: .numeric)))")
                    .appFont(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                if !log.body.isEmpty {
                    Text(log.body).appFont(.body).lineSpacing(4)
                }
                ForEach(log.photoURLs, id: \.self) { url in
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "photo").foregroundStyle(Color.appTextSecondary)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("訪問時の写真")
                    .accessibilityAddTraits(.isImage)
                }
            }
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .navigationTitle("訪問記")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .tabBar)
    }
}
#endif
