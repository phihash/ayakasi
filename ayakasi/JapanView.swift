import SwiftUI
import MapKit

// Data.swiftからayakasisをインポート

//保留
//YokaiDestination(name: "小豆島", coordinate: CLLocationCoordinate2D(latitude: 34.4856, longitude: 134.2049), description: "", prefecture: "香川県", websiteURL: nil, imageURL: nil, highlights: nil),
//YokaiDestination(name: "京都", coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681), description: "", prefecture: "京都府", websiteURL: nil, imageURL: nil, highlights: nil),
//YokaiDestination(name: "調布", coordinate: CLLocationCoordinate2D(latitude: 35.6517, longitude: 139.5407), description: "", prefecture: "東京都", websiteURL: nil, imageURL: nil, highlights: nil),

// 妖怪関連の目的地（町・施設など）
let yokaiDestinations: [YokaiDestination] = [
    YokaiDestination(name: "遠野", coordinate: CLLocationCoordinate2D(latitude: 39.3306, longitude: 141.5336), description: "柳田國男の『遠野物語』の舞台として知られる岩手県内陸の地域。カッパや座敷わらしといった妖怪の伝承、昔話や神話が多く残されている。", prefecture: "岩手県", websiteURL: nil, imageURL: nil, highlights: nil),
    YokaiDestination(name: "三好", coordinate: CLLocationCoordinate2D(latitude: 34.0226, longitude: 133.8068), description: "三好市には、多くの妖怪伝説が残る。山の危険から子どもを守るため、大人たちが妖怪話を語り継いだとされる。", prefecture: "徳島県", websiteURL: nil, imageURL: nil, highlights: nil),
    YokaiDestination(name: "三次", coordinate: CLLocationCoordinate2D(latitude: 34.8051, longitude: 132.8540), description: "広島県北部に位置し、日本で唯一の「妖怪」をテーマにした公立博物館がある。妖怪物語『稲生物怪録（いのうもののけろく）』の舞台として知られる。", prefecture: "広島県", websiteURL: nil, imageURL: nil, highlights: nil),
    YokaiDestination(name: "福崎", coordinate: CLLocationCoordinate2D(latitude: 35.0076, longitude: 134.7576), description: "日本民俗学の父・柳田國男の生誕地として知られる「妖怪の町」。『遠野物語』『妖怪談義』などを著した柳田國男の故郷。", prefecture: "兵庫県", websiteURL: nil, imageURL: nil, highlights: nil),
    YokaiDestination(name: "境港", coordinate: CLLocationCoordinate2D(latitude: 35.5382, longitude: 133.2316), description: "漫画家・水木しげるの出身地として知られる「妖怪の町」。水木しげるロードには多数の妖怪ブロンズ像が並び、妖怪をテーマにした町おこしで有名。", prefecture: "鳥取県", websiteURL: nil, imageURL: nil, highlights: nil),
    YokaiDestination(name: "妖怪美術館", coordinate: CLLocationCoordinate2D(latitude: 34.4849724114415, longitude: 134.18594687139813), description: "妖怪をテーマにした美術館。日本各地の妖怪文化や伝承を学べる。", prefecture: "香川県", websiteURL: nil, imageURL: nil, highlights: nil),
    YokaiDestination(name: "三次もののけミュージアム", coordinate: CLLocationCoordinate2D(latitude: 34.815692632661396, longitude: 132.8451409270821), description: "日本で唯一の「妖怪」をテーマにした公立博物館。『稲生物怪録』に登場する妖怪や、日本各地の妖怪文化を展示している。", prefecture: "広島県", websiteURL: nil, imageURL: nil, highlights: nil),
    YokaiDestination(name: "鬼の交流博物館", coordinate: CLLocationCoordinate2D(latitude: 35.45920848125813, longitude: 135.1446215106701), description: "日本の鬼伝説や文化を紹介する博物館。大江山の酒呑童子伝説をはじめ、全国の鬼に関する資料を展示している。", prefecture: "京都府", websiteURL: nil, imageURL: nil, highlights: nil),
]

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
            return ("sparkles", .blue)
        case .museum:
            return ("building.columns", .purple)
        case .culturalSite:
            return ("building", .orange)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Map(position: $viewModel.cameraPosition) {
                    // 妖怪関連スポット（赤いマーカー）
                    ForEach(yokaiDestinations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            Button {
                                viewModel.selectedLocation = .destination(location.id)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
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
                .frame(height: geometry.size.height * 0.6)

                VStack {
                    if let selectedLocation = viewModel.selectedLocation {
                        switch selectedLocation {
                        case .destination(let destinationId):
                            if let location = yokaiDestinations.first(where: { $0.id == destinationId }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Circle()
                                            .fill(.red)
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
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
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
                                            .fixedSize(horizontal: false, vertical: true)
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
                                                                        .fill(Color.blue)
                                                                )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            }
                        }
                    } else {
                        Text("地図上のマーカーをタップしてください")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: geometry.size.height * 0.4)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            }
        }
        .fullScreenCover(item: $selectedYokai) { yokai in
            NeoDetail(yokai: yokai)
        }
    }
}

