import SwiftUI
import MapKit

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
    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 136.8232),
            span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12)
        )
    )
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

    // ゆかりの地として登録された町・施設枠のスポットは、妖怪側のゆかりの地と同じ見た目にそろえる
    private func destinationIconAndColor(for destination: YokaiDestination) -> (icon: String, color: Color) {
        destination.kind == "related" ? spotIconAndColor(for: .yokaiRelated) : ("building.2", Color.appError)
    }

    // Google Mapで開く
    private func openInGoogleMaps(latitude: Double, longitude: Double, name: String) {
        let urlString = "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    @State private var showSheet = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.35)

    var body: some View {
        NavigationStack {
        Map(position: $viewModel.cameraPosition) {
            // 妖怪関連スポット（赤いマーカー）
            ForEach(yokaiDestinations.filter(filter.shows)) { location in
                let iconAndColor = destinationIconAndColor(for: location)
                Annotation(location.name, coordinate: location.coordinate) {
                    Button {
                        viewModel.selectedLocation = .destination(location.id)
                        selectedDetent = .medium
                        showSheet = true
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
                        viewModel.selectedLocation = .yokaiSpot(spot.id)
                        selectedDetent = .medium
                        showSheet = true
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
        .safeAreaInset(edge: .bottom) {
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
            // 白いシートはタブバーの裏(画面下端)まで伸ばす
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                    .fill(Color.appCardBackground)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .sheet(isPresented: $showSheet) {
            ScrollView {
                if let selectedLocation = viewModel.selectedLocation {
                    switch selectedLocation {
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

                                            HStack(spacing: 8) {
                                                ForEach(relatedYokais) { yokai in
                                                    Button {
                                                        selectedYokai = yokai
                                                    } label: {
                                                        Text(yokai.name)
                                                            .font(.subheadline)
                                                            .fontWeight(.medium)
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 6)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .fill(Color.appSecondary)
                                                            )
                                                    }
                                                    .buttonStyle(.plain)
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
            }
            .padding(.top, 16)
            .presentationDetents([.medium, .fraction(0.9)], selection: $selectedDetent)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled)
            .presentationBackground(.ultraThinMaterial)
        }
        .navigationDestination(item: $selectedYokai) { yokai in
            NeoDetail(yokai: yokai)
        }
        .navigationBarHidden(true)
        }
    }
}

