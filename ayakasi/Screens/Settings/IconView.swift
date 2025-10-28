import SwiftUI

let icons : [String] = [
    "kozou","kappaicon","oniicon","yukiicon"
]

struct IconView: View {
    @EnvironmentObject var colorVM : ColorViewModel
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
    var body: some View {
        NavigationStack{
            LazyVGrid(columns: columns){
                ForEach(icons, id : \.self){ icon in
                    VStack{
                      Image(icon)
                            .resizable()
                            .scaledToFit()
                    }
                    .onTapGesture {
                        colorVM.changeIcon(iconName: icon)
                    }
                }
            }
            
            .padding(.horizontal,12)
            .navigationTitle("アイコン変更")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
