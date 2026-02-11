import SwiftUI
import MapKit

struct YokaiLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct JapanView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 136.8232),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )

    let locations: [YokaiLocation] = [
        YokaiLocation(name: "小豆島", coordinate: CLLocationCoordinate2D(latitude: 34.4856, longitude: 134.2049)),
        YokaiLocation(name: "遠野", coordinate: CLLocationCoordinate2D(latitude: 39.3306, longitude: 141.5336)),
        YokaiLocation(name: "三好", coordinate: CLLocationCoordinate2D(latitude: 34.0226, longitude: 133.8068)),
        YokaiLocation(name: "三次", coordinate: CLLocationCoordinate2D(latitude: 34.8051, longitude: 132.8540)),
        YokaiLocation(name: "京都", coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681)),
        YokaiLocation(name: "調布", coordinate: CLLocationCoordinate2D(latitude: 35.6517, longitude: 139.5407)),
        YokaiLocation(name: "福崎", coordinate: CLLocationCoordinate2D(latitude: 35.0076, longitude: 134.7576)),
        YokaiLocation(name: "境港", coordinate: CLLocationCoordinate2D(latitude: 35.5382, longitude: 133.2316))
    ]

    var body: some View {
        VStack(spacing: 0) {
            Map(initialPosition: .region(region)) {
                ForEach(locations) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            Text(location.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)

            VStack {
                Text("Coming Soon...")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
        }
    }
}

