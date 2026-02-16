import SwiftUI
import MapKit

//保留
//TownRevitalization(townName: "小豆島", coordinate: CLLocationCoordinate2D(latitude: 34.4856, longitude: 134.2049), description: "", prefecture: "香川県", websiteURL: nil, imageURL: nil, highlights: nil),
//TownRevitalization(townName: "京都", coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681), description: "", prefecture: "京都府", websiteURL: nil, imageURL: nil, highlights: nil),
//TownRevitalization(townName: "調布", coordinate: CLLocationCoordinate2D(latitude: 35.6517, longitude: 139.5407), description: "", prefecture: "東京都", websiteURL: nil, imageURL: nil, highlights: nil),
//TownRevitalization(townName: "境港", coordinate: CLLocationCoordinate2D(latitude: 35.5382, longitude: 133.2316), description: "", prefecture: "鳥取県", websiteURL: nil, imageURL: nil, highlights: nil)

// 町おこしデータ
let townRevitalizations: [TownRevitalization] = [
    TownRevitalization(townName: "遠野", coordinate: CLLocationCoordinate2D(latitude: 39.3306, longitude: 141.5336), description: "柳田國男の『遠野物語』の舞台として知られる岩手県内陸の地域。カッパや座敷わらしといった妖怪の伝承、昔話や神話が多く残されている。", prefecture: "岩手県", websiteURL: nil, imageURL: nil, highlights: nil),
    TownRevitalization(townName: "三好", coordinate: CLLocationCoordinate2D(latitude: 34.0226, longitude: 133.8068), description: "", prefecture: "徳島県", websiteURL: nil, imageURL: nil, highlights: nil),
    TownRevitalization(townName: "三次", coordinate: CLLocationCoordinate2D(latitude: 34.8051, longitude: 132.8540), description: "", prefecture: "広島県", websiteURL: nil, imageURL: nil, highlights: nil),
    TownRevitalization(townName: "福崎", coordinate: CLLocationCoordinate2D(latitude: 35.0076, longitude: 134.7576), description: "", prefecture: "兵庫県", websiteURL: nil, imageURL: nil, highlights: nil),
]

@Observable
@MainActor
class JapanViewModel  {
    var selectedLocationID: TownRevitalization.ID?
    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 136.8232),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
}

struct JapanView: View {
    @State private var viewModel = JapanViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedLocationID) {
                    ForEach(townRevitalizations) { location in
                        Marker(location.townName, coordinate: location.coordinate)
                            .tint(.red)
                            .tag(location.id)
                    }
                }
                .frame(height: geometry.size.height * 0.7)

                VStack {
                    if let selectedId = viewModel.selectedLocationID,
                       let location = townRevitalizations.first(where: { $0.id == selectedId }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(location.townName)
                                .font(.title2)
                                .fontWeight(.bold)

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
                    } else {
                        Text("地図上のマーカーをタップしてください")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: geometry.size.height * 0.3)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            }
        }
    }
}

