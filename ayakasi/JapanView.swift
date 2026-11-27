import SwiftUI
import MapKit
import Kingfisher

// 妖怪関連の目的地はdata.jsonのdestinations配列から供給(YokaiStore)

enum SelectedLocationType {
    case destination(YokaiDestination.ID)
    case yokaiSpot(YokaiSpot.ID)
}

// マップ下部のチップで絞り込む種類
enum MapFilter: String, CaseIterable {
    case all = "すべて"
    case town = "町"
    case related = "ゆかりの地"
    case facility = "施設"

    func shows(_ destination: YokaiDestination) -> Bool {
        switch destination.kind {
        case "facility": return self == .all || self == .facility
        case "related": return self == .all || self == .related
        default: return self == .all || self == .town
        }
    }

    func shows(_ spot: YokaiSpot) -> Bool {
        self == .all || self == (spot.spotType == .yokaiRelated ? .related : .facility)
    }
}

@Observable
@MainActor
class JapanViewModel  {
    var selectedLocation: SelectedLocationType?
    static let initialCamera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 136.8232),
            span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12)
        )
    )
    var cameraPosition: MapCameraPosition = JapanViewModel.initialCamera
}

struct JapanView: View {
    @State private var viewModel = JapanViewModel()
    @State private var selectedYokai: Ayakasi?
    @State private var filter: MapFilter = .all

    // ayakasisから全てのスポットを抽出
    private var allYokaiSpots: [YokaiSpot] { YokaiStore.shared.spots }

    // スポットタイプに応じたアイコンとカラーを返す
    // ゆかりの地は妖怪の顔で見分けられるよう、角丸正方形にその妖怪の画像を出す(画像が無ければ従来のアイコン)
    private func yokaiPin(_ yokai: Ayakasi, color: Color) -> some View {
        ZStack {
            if yokai.imageName == "NoImage" {
                iconPin("sparkles", color: color)
            } else {
                RoundedRectangle(cornerRadius: 8).fill(color)
                KFImage(URL(string: yokai.imageName))
                    .downsampling(size: CGSize(width: 40, height: 40))
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(width: 36, height: 36)
        .shadow(radius: 3)
    }

    private func iconPin(_ icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .foregroundColor(.white)
            .font(.system(size: 15))
            .frame(width: 36, height: 36)
            .background(RoundedRectangle(cornerRadius: 8).fill(color))
            .shadow(radius: 3)
    }

    private func spotIconAndColor(for spotType: SpotType) -> (icon: String, color: Color) {
        switch spotType {
        case .yokaiRelated:
            return ("sparkles", Color.appSecondary)
        case .museum:
            return ("building.columns", Color.appAccent)
        case .culturalSite:
            return ("building", Color.appPrimary)
        }
    }

    // destinationsのゆかりの地・施設は、妖怪側スポットの同じ種類と見た目をそろえる(チップと同じ分類で見分けられるように)
    private func destinationIconAndColor(for destination: YokaiDestination) -> (icon: String, color: Color) {
        switch destination.kind {
        case "related": return spotIconAndColor(for: .yokaiRelated)
        case "facility": return spotIconAndColor(for: .museum)
        default: return ("building.2", Color.appError)
        }
    }

    // 関連妖怪の正方形サムネイル。画像が無い妖怪はカードと同じ「No Image」表示にそろえる
    @ViewBuilder
    private func yokaiThumbnail(_ yokai: Ayakasi) -> some View {
        if yokai.imageName == "NoImage" {
            ZStack {
                Color.gray.opacity(0.12)
                Image(systemName: "questionmark.square")
                    .font(.system(size: 28))
                    .foregroundColor(.appTextSecondary)
            }
        } else {
            KFImage(URL(string: yokai.imageName))
                .placeholder { Color.gray.opacity(0.12) }
                .downsampling(size: CGSize(width: 120, height: 120))
                .scaleFactor(UIScreen.main.scale)
                .cacheOriginalImage()
                .resizable()
                .scaledToFill()
        }
    }

    // 下のシートに出すスポット詳細(標準.sheetは途中の高さで画面端から浮いて隙間ができるため自前で置く)
    @ViewBuilder
    private func spotPanel(_ selection: SelectedLocationType) -> some View {
        switch selection {
        case .destination(let destinationId):
            if let location = yokaiDestinations.first(where: { $0.id == destinationId }) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(destinationIconAndColor(for: location).color)
                            .frame(width: 12, height: 12)
                        Text(location.name)
                            .appFont(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.trailing, 44)

                    Text(location.prefecture)
                        .appFont(.subheadline)
                        .foregroundColor(.secondary)

                    if !location.description.isEmpty {
                        Text(location.description)
                            .appFont(.body)
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top, 8)
            }
        case .yokaiSpot(let spotId):
            if let spot = allYokaiSpots.first(where: { $0.id == spotId }) {
                let relatedYokai = spot.yokaiIds.compactMap(yokaiById)
                VStack(alignment: .leading, spacing: 0) {
                    let summary = spotSummary(spot, relatedYokai: relatedYokai)
                    if let first = relatedYokai.first {
                        if relatedYokai.count == 1 {
                            Button { selectedYokai = first } label: { summary }
                                .buttonStyle(.plain)
                                .accessibilityHint("\(first.name)の詳細を開く")
                        } else {
                            Menu {
                                ForEach(relatedYokai) { yokai in
                                    Button(yokai.name) { selectedYokai = yokai }
                                }
                            } label: { summary }
                            .buttonStyle(.plain)
                        }
                    } else {
                        summary
                    }

                    #if DEBUG  // スポット画面(ログ)は仮UIなのでリリース版には出さない
                    if spot.spotType == .yokaiRelated {
                        NavigationLink {
                            SpotDetailView(spot: spot)
                        } label: {
                            Label("スポットを見る", systemImage: "mappin.and.ellipse")
                                .appFont(.subheadline, weight: .semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.appSecondary))
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    #endif
                }
            }
        }
    }

    private func spotSummary(_ spot: YokaiSpot, relatedYokai: [Ayakasi]) -> some View {
        let marker = spotIconAndColor(for: spot.spotType)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: marker.icon)
                    .foregroundStyle(.white)
                    .font(.system(size: 10))
                    .frame(width: 20, height: 20)
                    .background(marker.color, in: RoundedRectangle(cornerRadius: 5))
                Text(spot.spotName)
                    .appFont(.title2, weight: .bold)
            }
            .padding(.trailing, 44)

            Text(spot.prefecture)
                .appFont(.subheadline)
                .foregroundStyle(.secondary)
            if let description = spot.description {
                Text(description)
                    .appFont(.body)
            }

            if let first = relatedYokai.first {
                VStack(alignment: .leading, spacing: 6) {
                    Text("関連する妖怪:")
                        .appFont(.caption)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            yokaiThumbnail(first)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            #if DEBUG
                            SpotPhotoStrip(spot: spot)
                            #endif
                        }
                    }
                    Text(relatedYokai.map(\.name).joined(separator: "・"))
                        .appFont(.subheadline, weight: .semibold)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .padding(.top, 8)
        .contentShape(Rectangle())
    }

    var body: some View {
        NavigationStack {
        Map(position: $viewModel.cameraPosition) {
            // 妖怪関連スポット（赤いマーカー）
            ForEach(yokaiDestinations.filter(filter.shows)) { location in
                let iconAndColor = destinationIconAndColor(for: location)
                Annotation(location.name, coordinate: location.coordinate) {
                    Button {
                        withAnimation(.snappy) { viewModel.selectedLocation = .destination(location.id) }
                        Analytics.trackMapSpotTapped(spotName: location.name, prefecture: location.prefecture)
                    } label: {
                        iconPin(iconAndColor.icon, color: iconAndColor.color)
                    }
                }
            }

            // 妖怪スポット（タイプ別のAnnotation）
            ForEach(allYokaiSpots.filter(filter.shows)) { spot in
                let iconAndColor = spotIconAndColor(for: spot.spotType)
                Annotation(spot.spotName, coordinate: spot.coordinate) {
                    Button {
                        withAnimation(.snappy) { viewModel.selectedLocation = .yokaiSpot(spot.id) }
                        Analytics.trackMapSpotTapped(spotName: spot.spotName, prefecture: spot.prefecture)
                    } label: {
                        if spot.spotType == .yokaiRelated, let yokai = spot.yokaiIds.first.flatMap(yokaiById) {
                            yokaiPin(yokai, color: iconAndColor.color)
                        } else {
                            iconPin(iconAndColor.icon, color: iconAndColor.color)
                        }
                    }
                }
            }
        }
        // safeAreaInsetにしないのは、シートの高さアニメーション中に地図の表示領域まで伸び縮みしてカメラが跳ねるから
        .overlay(alignment: .bottom) {
            VStack(alignment: .trailing, spacing: 12) {
                Button {
                    withAnimation(.easeOut(duration: 0.3)) { viewModel.cameraPosition = JapanViewModel.initialCamera }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appSecondary)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.appCardBackground))
                        .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
                }
                .accessibilityLabel("日本全体の表示に戻す")
                .padding(.trailing, 16)
                Group {
                    if let selection = viewModel.selectedLocation {
                        spotPanel(selection)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    withAnimation(.snappy) { viewModel.selectedLocation = nil }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color.appTextSecondary)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(Color.appTextPrimary.opacity(0.08)))
                                }
                                .accessibilityLabel("閉じる")
                                .padding(.top, 20)
                                .padding(.trailing, 16)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(MapFilter.allCases, id: \.self) { item in
                                    let isSelected = item == filter
                                    Button {
                                        filter = item
                                    } label: {
                                        Text(item.rawValue)
                                            .appFont(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(isSelected ? Color.appSecondary : Color.appTextSecondary)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 10)
                                            .background(Capsule().fill(isSelected ? Color.appCardBackground : Color.appTextPrimary.opacity(0.06)))
                                            .overlay(Capsule().stroke(isSelected ? Color.appSecondary : .clear, lineWidth: 2))
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        }
                        .transition(.opacity)
                    }
                }
                // 白いシートはタブバーの裏(画面下端)まで伸ばす
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                        .fill(Color.appCardBackground)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .navigationDestination(item: $selectedYokai) { yokai in
            NeoDetail(yokai: yokai, source: "map")
        }
        .navigationBarHidden(true)
        }
    }
}


#if DEBUG
/// そのスポットの訪問記に付いた写真を、妖怪の画像の横に並べる
private struct SpotPhotoStrip: View {
    let spot: YokaiSpot
    @State private var urls: [URL] = []

    var body: some View {
        HStack(spacing: 8) {
            ForEach(urls, id: \.self) { url in
                KFImage(url)
                    .placeholder { Color.gray.opacity(0.12) }
                    .downsampling(size: CGSize(width: 120, height: 120))
                    .scaleFactor(UIScreen.main.scale)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityLabel("訪問時の写真")
            }
        }
        .task(id: spot.id) {
            urls = []
            var found: [URL] = []
            // 訪問記のAPIは妖怪ごとなので、関連妖怪の数だけ取りに行く
            for yokaiId in spot.yokaiIds {
                let logs = (try? await SpotLogAPI.list(yokaiId: yokaiId, spot: spot)) ?? []
                found += logs.flatMap(\.photoURLs)
            }
            guard !Task.isCancelled else { return }
            urls = Array(found.prefix(10))
        }
    }
}
#endif
