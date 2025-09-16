import SwiftUI

struct Xkai: View {
    let ayakasis: [Ayakasi]
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    @State private var selectedYokai : Ayakasi?
    @Environment(\.dismiss) private var dismiss
    let screenWidth = UIScreen.main.bounds.width
    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                HStack{
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: screenWidth * 0.1, height: screenWidth * 0.1)
                        .overlay(
                            Image(systemName: "xmark")
                                .foregroundStyle(.white)
                                .padding()
                        )
                        .onTapGesture {
                            dismiss()
                        }
                }
                .padding(.horizontal,20)
                .padding(.bottom,12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
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
            .navigationTitle("現代の怪")
            .navigationBarTitleDisplayMode(.inline)

        }
    }
}
