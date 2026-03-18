import SwiftUI

struct NewsSection: View {
    @Binding var selectedNews: String
    let newsYokai: [String]

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

            HStack{
                ForEach(newsYokai, id: \.self) { element in
                    Button{
                        selectedNews = element
                    } label :{
                        Text(element)
                            .font(.subheadline)
                            .foregroundStyle(selectedNews == element ? Color.white : Color.appSecondary)
                            .fontWeight(.bold)
                            .padding(.vertical,6)
                            .padding(.horizontal,18)
                            .background(selectedNews == element ? Color.appSecondary : Color.clear)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.appSecondary, lineWidth: 2)
                            )
                            .onTapGesture { selectedNews = element }
                    }
                }
                Spacer()
            }
            .font(.headline)
            .fontWeight(.bold)
            .padding(.horizontal,20)
            .padding(.vertical,16)

            NewsView(selectedNew: selectedNews)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            let currentNewsIndex = newsYokai.firstIndex(of: selectedNews) ?? 0

                            if value.translation.width > 50 {
                                let newIndex = max(0, currentNewsIndex - 1)
                                withAnimation{
                                    selectedNews = newsYokai[newIndex]
                                }
                            } else if value.translation.width < -50 {
                                let newIndex = min(newsYokai.count - 1, currentNewsIndex + 1)
                                withAnimation{
                                    selectedNews = newsYokai[newIndex]
                                }
                            }
                        }
                )
        }
    }
}
