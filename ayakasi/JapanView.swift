import SwiftUI
import MapKit

// 妖怪関連の目的地はdata.jsonのdestinations配列から供給(YokaiStore)

enum SelectedLocationType {
    case destination(YokaiDestination.ID)
    case yokaiSpot(YokaiSpot.ID)
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
            ForEach(yokaiDestinations) { location in
                Annotation(location.name, coordinate: location.coordinate) {
                    Button {
                        viewModel.selectedLocation = .destination(location.id)
                        selectedDetent = .medium
                        showSheet = true
                        Analytics.trackMapSpotTapped(spotName: location.name, prefecture: location.prefecture)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.appError)
                                .frame(width: 30, height: 30)
                            Image(systemName: "building.2")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .shadow(radius: 3)
                    }
                }
            }

            // 妖怪スポット（タイプ別のAnnotation）
            ForEach(allYokaiSpots) { spot in
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
        .sheet(isPresented: $showSheet) {
            ScrollView {
                if let selectedLocation = viewModel.selectedLocation {
                    switch selectedLocation {
                    case .destination(let destinationId):
                        if let location = yokaiDestinations.first(where: { $0.id == destinationId }) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Circle()
                                        .fill(Color.appError)
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

