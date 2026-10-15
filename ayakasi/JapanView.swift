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
    private var allYokaiSpots: [YokaiSpot] {
        let yokaiRelatedSpots = ayakasis.compactMap { yokai in
            yokai.relatedSpots
        }.flatMap { $0 }

        return yokaiRelatedSpots
    }

    // yokaiIdsから妖怪オブジェクトを取得
    private func getYokaiFromIds(_ ids: [String]) -> [Ayakasi] {
        ids.compactMap { id in
            ayakasis.first { $0.documentId == id }
        }
    }

    // スポットタイプに応じたアイコンとカラーを返す
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

    // Google Mapで開く
    private func openInGoogleMaps(latitude: Double, longitude: Double, name: String) {
        let urlString = "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
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
                        Circle()
                            .fill(destinationIconAndColor(for: location).color)
                            .frame(width: 12, height: 12)
                        Text(location.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.trailing, 44)

                    Text(location.prefecture)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if !location.description.isEmpty {
                        Text(location.description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    Button {
                        openInGoogleMaps(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, name: location.name)
                    } label: {
                        HStack {
                            Image(systemName: "map")
                            Text("Google Mapで開く")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.appSecondary)
                        .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        case .yokaiSpot(let spotId):
            if let spot = allYokaiSpots.first(where: { $0.id == spotId }) {
                let iconAndColor = spotIconAndColor(for: spot.spotType)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(iconAndColor.color)
                                .frame(width: 20, height: 20)
                            Image(systemName: iconAndColor.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 10))
                        }
                        Text(spot.spotName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.trailing, 44)

                    Text(spot.prefecture)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let description = spot.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    if !spot.yokaiIds.isEmpty {
                        let relatedYokais = getYokaiFromIds(spot.yokaiIds)
                        if !relatedYokais.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("関連する妖怪:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(relatedYokais) { yokai in
                                            Button {
                                                selectedYokai = yokai
                                            } label: {
                                                VStack(alignment: .leading, spacing: 6) {
                                                    yokaiThumbnail(yokai)
                                                        .frame(width: 120, height: 120)
                                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                    Text(yokai.name)
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(Color.appTextPrimary)
                                                        .lineLimit(1)
                                                        .frame(width: 120, alignment: .leading)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        openInGoogleMaps(latitude: spot.coordinate.latitude, longitude: spot.coordinate.longitude, name: spot.spotName)
                    } label: {
                        HStack {
                            Image(systemName: "map")
                            Text("Google Mapで開く")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.appSecondary)
                        .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
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
                        ZStack {
                            Circle()
                                .fill(iconAndColor.color)
                                .frame(width: 30, height: 30)
                            Image(systemName: iconAndColor.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .shadow(radius: 3)
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
                        ZStack {
                            Circle()
                                .fill(iconAndColor.color)
                                .frame(width: 30, height: 30)
                            Image(systemName: iconAndColor.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .shadow(radius: 3)
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
                            .padding(.top, 8)
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
                                            .font(.subheadline)
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
            NeoDetail(yokai: yokai)
        }
        .navigationBarHidden(true)
        }
    }
}

