import SwiftUI

struct JapanView: View {
    @State private var page = 0
    let tests: [String] = ["1", "2", "3"]
    var body: some View {
        TabView(selection: $page) {
            ForEach(tests.indices, id: \.self) { index in
                Text("テスト")
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 160)
    }
}

