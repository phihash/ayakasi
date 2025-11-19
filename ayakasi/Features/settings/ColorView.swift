import SwiftUI

let colors : [String] = [
    "customOrange","customPink","customRed","customBlue","customGreen"
]

struct ColorView: View {
    @EnvironmentObject var colorVM : ColorViewModel
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    var body: some View {
        NavigationStack{
                    LazyVGrid(columns: columns){
                        ForEach(colors, id : \.self){ color in
                        VStack{
                            Rectangle()
                                .fill(Color(color))
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color(UIColor.separator), lineWidth: 3)
                                )
                            
                            Text(color)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                        }
                        .onTapGesture {
                            colorVM.changeColor(colorName: color)
                        }
                    }
                }
                
            
            .padding(.horizontal,12)
            .navigationTitle("カラー変更")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
