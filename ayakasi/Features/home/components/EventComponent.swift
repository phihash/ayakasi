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
            ZStack{
                Rectangle()
                    .fill(colorName)
                    .frame(width: screenWidth * 0.9)
                    .cornerRadius(12)
                
                HStack{
                    Text(linkTitle)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                    
                    Image(iconName).resizable().scaledToFit()
                        .frame(width: screenWidth * 0.24)
                        .padding(.leading,20)
                }
                
            }
        }
    }
}
