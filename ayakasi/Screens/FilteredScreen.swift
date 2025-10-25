import SwiftUI

struct FilteredScreen: View {
    let ayakasis: [Ayakasi] 
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    let tag : String
    @State private var selectedYokai : Ayakasi? = nil
    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                LazyVGrid(columns: columns){
                    ForEach(ayakasis){ayakasi in
                        PickupCard(ayakasi: ayakasi)
                        .onTapGesture{
                            selectedYokai = ayakasi
                        }
                        .fullScreenCover(item: $selectedYokai){ yokai in
                            NeoDetail(yokai: yokai)
                        }
                    }
                }
            }
            .background(Color("Ivory"))
            .navigationTitle(tag)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}



