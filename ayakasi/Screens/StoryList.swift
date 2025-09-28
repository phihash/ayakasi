import SwiftUI

struct StoryList: View {
    let screenWidth = UIScreen.main.bounds.width
    @State private var isYukiShow = false
    @State private var isWarasiShow = false
    @State private var isKiyohimeShow = false
    @State private var isOitekeShow = false
    @State private var isYamanbaShow = false
    @EnvironmentObject var colorVM : ColorViewModel
    var body: some View {
        NavigationStack{
            ZStack{
                Color.naturalGray.edgesIgnoringSafeArea(.all)
                ScrollView(showsIndicators: false){
                    HStack{
                        Rectangle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 100 , height: 100)
                            .cornerRadius(12)
                            .overlay{
                                Image("yukiicon")
                                    .resizable()
                                    .frame(width: 90 ,height: 90)
                            }
                        
                        VStack(alignment: .leading){
                            
                            
                            VStack (alignment: .leading) {
                                Text("ある冬の出来事でした")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                Text("雪女")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical,8)
                                    .padding(.horizontal,10)
                                    .background(Rectangle().fill(.blue.opacity(0.6)).cornerRadius(6))
                            }
                            .padding(.leading, 18)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading,32)
                    .padding(.vertical,16)
                    .contentShape(Rectangle())  
                    .onTapGesture {
                        isYukiShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isYukiShow){
                        Yuki()
                    }
                    
                    
                    Divider()
                    
                    HStack{
                        Rectangle()
                            .fill(.green.opacity(0.2))
                            .frame(width: 100 , height: 100)
                            .cornerRadius(12)
                            .overlay{
                                Image("warasiicon")
                                    .resizable()
                                    .frame(width: 90 ,height: 90)
                            }
                        
                        VStack(alignment: .leading){
                            
                            
                            VStack (alignment: .leading) {
                                Text("東北の古い家")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                Text("座敷童子")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical,8)
                                    .padding(.horizontal,10)
                                    .background(Rectangle().fill(.green.opacity(0.6)).cornerRadius(6))
                            }
                            .padding(.leading, 18)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading,32)
                    .padding(.vertical,16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isWarasiShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isWarasiShow){
                        Zasikiwarasi()
                    }
                    
                    
                    Divider()
                    
                    HStack{
                        Rectangle()
                            .fill(.red.opacity(0.2))
                            .frame(width: 100 , height: 100)
                            .cornerRadius(12)
                            .overlay{
                                Image("noppe")
                                    .resizable()
                                    .frame(width: 90 ,height: 90)
                            }
                        
                        VStack(alignment: .leading){
                            
                            
                            VStack (alignment: .leading) {
                                Text("おいてけ堀")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                Text("のっぺらぼう")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical,8)
                                    .padding(.horizontal,10)
                                    .background(Rectangle().fill(.red.opacity(0.6)).cornerRadius(6))
                            }
                            .padding(.leading, 18)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading,32)
                    .padding(.vertical,16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isOitekeShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isOitekeShow){
                        Oiteke()
                    }
                    
                    
                    
                    Divider()
                    
                    
                    HStack{
                        Rectangle()
                            .fill(.orange.opacity(0.2))
                            .frame(width: 100 , height: 100)
                            .cornerRadius(12)
                            .overlay{
                                Image("kiyohime")
                                    .resizable()
                                    .frame(width: 90 ,height: 90)
                            }
                        
                        VStack(alignment: .leading){
                            
                            
                            VStack (alignment: .leading) {
                                Text("若き僧と清姫との出会い")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                Text("安珍清姫")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical,8)
                                    .padding(.horizontal,10)
                                    .background(Rectangle().fill(.orange.opacity(0.6)).cornerRadius(6))
                            }
                            .padding(.leading, 18)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading,32)
                    .padding(.vertical,16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isKiyohimeShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isKiyohimeShow ){
                        Kiyohime()
                    }
                    
                    
                    Divider()
                    
                    HStack{
                        Rectangle()
                            .fill(.purple.opacity(0.2))
                            .frame(width: 100 , height: 100)
                            .cornerRadius(12)
                            .overlay{
                                Image("oba")
                                    .resizable()
                                    .frame(width: 90 ,height: 90)
                            }
                        
                        VStack(alignment: .leading){
                            
                            
                            VStack (alignment: .leading) {
                                Text("3枚のおふだ")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                Text("やまんば")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical,8)
                                    .padding(.horizontal,10)
                                    .background(Rectangle().fill(.purple.opacity(0.6)).cornerRadius(6))
                            }
                            .padding(.leading, 18)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading,32)
                    .padding(.vertical,16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isYamanbaShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isYamanbaShow ){
                        Yamanba()
                    }
                
            }
            .padding(.vertical,30)
        }
        .navigationTitle("おはなし")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    
}

}

//
//
//HStack{
//    Image(systemName: "star")
//    Text("安珍清姫伝説")
//}
//.font(.headline)
//.foregroundStyle(.white)
//.frame(width: screenWidth * 0.8, height: 48)
//.background(Capsule().fill(.orange))
