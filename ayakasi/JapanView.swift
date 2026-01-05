import SwiftUI

struct JapanView: View {
    @State private var page = 0
    let tests: [String] = ["小豆島", "遠野", "三好","三次", "京都", "調布","福崎","境港"]
    
    // カラーバリエーション
    let colors: [Color] = [.blue, .green, .red, .orange, .purple, .pink, .yellow, .gray]
    
    var body: some View {
        TabView(selection: $page) {
            ForEach(tests.indices, id: \.self) { index in
                ZStack {
                    Rectangle()
                        .fill(colors[index % colors.count])
                        .aspectRatio(1.0, contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text(tests[index])
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1)
                }
                .padding(.horizontal, 20)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 300)
    }
}

