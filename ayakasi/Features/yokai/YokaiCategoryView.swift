import SwiftUI

struct YokaiCategoryView: View {
    let ayakasis: [Ayakasi]
    let title : String
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    @State private var selectedYokai : Ayakasi?
    @Environment(\.dismiss) private var dismiss
    let screenWidth = UIScreen.main.bounds.width
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
                .padding(.vertical,12)
            }
            .background(Color("Ivory"))
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("閉じる"){
                        dismiss()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)

        }
    }
}
