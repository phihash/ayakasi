import SwiftUI

struct RankingSectionView: View {
    let rankedYokai: [Ayakasi]
    @Binding var selectedYokai: Ayakasi?

    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("ランキング")
                Spacer()
            }
            .font(.headline)
            .fontWeight(.bold)
            .padding(.horizontal,20)
            .padding(.vertical,12)

            ScrollView(.horizontal,showsIndicators: false){
                HStack(spacing: 16){
                    ForEach(rankedYokai.prefix(9)){ ayakasi in
                        NeoCardItem(item: ayakasi)
                            .onTapGesture{
                                selectedYokai = ayakasi
                            }
                    }
                }
                .padding(.horizontal,20)
                .padding(.bottom,24)
            }
        }
    }
}
