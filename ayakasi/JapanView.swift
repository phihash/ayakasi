import SwiftUI
import MapKit

// Data.swiftからayakasisをインポート

//保留
//TownRevitalization(townName: "小豆島", coordinate: CLLocationCoordinate2D(latitude: 34.4856, longitude: 134.2049), description: "", prefecture: "香川県", websiteURL: nil, imageURL: nil, highlights: nil),
//TownRevitalization(townName: "京都", coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681), description: "", prefecture: "京都府", websiteURL: nil, imageURL: nil, highlights: nil),
//TownRevitalization(townName: "調布", coordinate: CLLocationCoordinate2D(latitude: 35.6517, longitude: 139.5407), description: "", prefecture: "東京都", websiteURL: nil, imageURL: nil, highlights: nil),
//TownRevitalization(townName: "境港", coordinate: CLLocationCoordinate2D(latitude: 35.5382, longitude: 133.2316), description: "", prefecture: "鳥取県", websiteURL: nil, imageURL: nil, highlights: nil)

// 町おこしデータ
let townRevitalizations: [TownRevitalization] = [
    TownRevitalization(townName: "遠野", coordinate: CLLocationCoordinate2D(latitude: 39.3306, longitude: 141.5336), description: "柳田國男の『遠野物語』の舞台として知られる岩手県内陸の地域。カッパや座敷わらしといった妖怪の伝承、昔話や神話が多く残されている。", prefecture: "岩手県", websiteURL: nil, imageURL: nil, highlights: nil),
    TownRevitalization(townName: "三好", coordinate: CLLocationCoordinate2D(latitude: 34.0226, longitude: 133.8068), description: "三好市には、多くの妖怪伝説が残る。山の危険から子どもを守るため、大人たちが妖怪話を語り継いだとされる。", prefecture: "徳島県", websiteURL: nil, imageURL: nil, highlights: nil),
    TownRevitalization(townName: "三次", coordinate: CLLocationCoordinate2D(latitude: 34.8051, longitude: 132.8540), description: "広島県北部に位置し、日本で唯一の「妖怪」をテーマにした公立博物館がある。妖怪物語『稲生物怪録（いのうもののけろく）』の舞台として知られる。", prefecture: "広島県", websiteURL: nil, imageURL: nil, highlights: nil),
    TownRevitalization(townName: "福崎", coordinate: CLLocationCoordinate2D(latitude: 35.0076, longitude: 134.7576), description: "日本民俗学の父・柳田國男の生誕地として知られる「妖怪の町」。『遠野物語』『妖怪談義』などを著した柳田國男の故郷。", prefecture: "兵庫県", websiteURL: nil, imageURL: nil, highlights: nil),
    TownRevitalization(townName: "境港", coordinate: CLLocationCoordinate2D(latitude: 35.5382, longitude: 133.2316), description: "漫画家・水木しげるの出身地として知られる「妖怪の町」。水木しげるロードには多数の妖怪ブロンズ像が並び、妖怪をテーマにした町おこしで有名。", prefecture: "鳥取県", websiteURL: nil, imageURL: nil, highlights: nil),
]

// 妖怪スポットデータ
let yokaiSpots: [YokaiSpot] = [
    YokaiSpot(
        spotName: "道成寺",
        coordinate: CLLocationCoordinate2D(latitude: 33.914798277659315, longitude: 135.17422150000002),
        description: "安珍清姫の伝説で知られる天台宗の古刹。清姫が蛇となって安珍を追い詰め、鐘の中で焼き殺したという物語の舞台。",
        yokaiIds: ["kiyohime"],
        prefecture: "和歌山県",
        imageURL: nil
    ),
]

enum SelectedLocationType {
    case town(TownRevitalization.ID)
    case yokaiSpot(YokaiSpot.ID)
}

@Observable
@MainActor
class JapanViewModel  {
    var selectedLocation: SelectedLocationType?
    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 136.8232),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
}

struct JapanView: View {
    @State private var viewModel = JapanViewModel()

    // yokaiIdsから妖怪オブジェクトを取得
    private func getYokaiFromIds(_ ids: [String]) -> [Ayakasi] {
        ids.compactMap { id in
            ayakasis.first { $0.documentId == id }
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
            VStack(spacing: 0) {
                Map(position: $viewModel.cameraPosition) {
                    // 町おこしスポット（赤いマーカー）
                    ForEach(townRevitalizations) { location in
                        Annotation(location.townName, coordinate: location.coordinate) {
                            Button {
                                viewModel.selectedLocation = .town(location.id)
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

                    // 妖怪スポット（青いAnnotation）
                    ForEach(yokaiSpots) { spot in
                        Annotation(spot.spotName, coordinate: spot.coordinate) {
                            Button {
                                viewModel.selectedLocation = .yokaiSpot(spot.id)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 30, height: 30)
                                    Image(systemName: "sparkles")
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
                        case .town(let townId):
                            if let location = townRevitalizations.first(where: { $0.id == townId }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 12, height: 12)
                                        Text(location.townName)
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
                            if let spot = yokaiSpots.first(where: { $0.id == spotId }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(.blue)
                                                .frame(width: 20, height: 20)
                                            Image(systemName: "sparkles")
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
                                                        NavigationLink(destination: NeoDetail(yokai: yokai)) {
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
        }
    }
}

