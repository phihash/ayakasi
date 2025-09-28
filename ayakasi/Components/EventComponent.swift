import SwiftUI

struct EventComponent: View {
    
    @EnvironmentObject var colorVM : ColorViewModel
    @State private var ogImage: Image?
    let screenWidth = UIScreen.main.bounds.width
    let link : String
    let linkTitle : String
    let iconName : String
    
    var body: some View {
        Link(destination: URL(string: link)!){
            ZStack{
                Rectangle()
                    .fill(colorVM.currentColor)
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
