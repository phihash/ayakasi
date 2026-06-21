import SwiftUI

struct NewsSection: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("妖怪関連ニュース")
                Spacer()
            }
            .font(.headline)
            .fontWeight(.bold)
            .padding(.horizontal,20)
            .padding(.top,8)

            NewsView(selectedNew: "妖怪")
                .padding(.top, 16)
        }
    }
}
