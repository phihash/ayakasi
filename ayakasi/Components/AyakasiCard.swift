import SwiftUI

struct AyakasiCard : View{
    let ayakasi : Ayakasi
    var body: some View{
        NavigationLink{
            NeoDetail(yokai: ayakasi)
                .navigationBarBackButtonHidden(true)
        } label :{
            VStack(alignment: .leading,  spacing: 12){
                Image(ayakasi.imageName)
                    .resizable()
                    .scaledToFill()
                    .padding(.horizontal,12)
                Text(ayakasi.name)
                Text(ayakasi.description)
            }
            .padding()
            .foregroundStyle(Color.black)
            .background(Color.white)
            .cornerRadius(12)
            .padding()
     
        }
    }
}
