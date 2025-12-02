import SwiftUI


struct EventComponent: View {
    @State private var ogImage: Image?
    let screenWidth = UIScreen.main.bounds.width
    let link : String
    let linkTitle : String
    let iconName : String
    let colorName: Color
    
    var body: some View {
        Link(destination: URL(string: link)!){
            ZStack {
                AsyncImage(url: URL(string: "https://placehold.jp/380x160.png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(12)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(colorName)
                }
                
              
                
                VStack {
                    Spacer()
                    HStack {
                        Text(linkTitle)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                        Spacer()
                    }
                    .padding(.leading, 36)
                    .padding(.bottom, 24)
                }
            }
            .frame(width: screenWidth * 0.9, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
