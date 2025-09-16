import SwiftUI

struct StoryList: View {
    let screenWidth = UIScreen.main.bounds.width
    @State private var isYukiShow = false
    @State private var isWarasiShow = false
    @State private var isKiyohimeShow = false
    @State private var isOitekeShow = false
    var body: some View {
        NavigationStack{
            ZStack{
                Color.ivory.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false){
                    
                    VStack{
                        ZStack{
                            Rectangle()
                                .fill(.blue.opacity(0.5))
                                .frame(width: screenWidth * 0.9,height: 140)
                                .cornerRadius(24)
                            
                            HStack{
                                Text("雪女")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                             
                                Image("yukiicon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.24) // サイズ調整
                                    .padding(.leading,20)
                            }
                            
                        }
                        HStack{
                            VStack{
                                Text("【冬の夜の出来事】")
                                    .font(.headline)
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Capsule()
                                .stroke(Color.black.opacity(0.6),lineWidth: 1)
                                .frame(width: screenWidth * 0.16, height: screenWidth * 0.08)
                            .overlay(
                                Text("雪女")
                                    .foregroundStyle(Color.black.opacity(0.5))
                                    .fontWeight(.bold)
                                    .font(.callout)
                            )
                           
                        }
                        .frame(width: screenWidth * 0.86 , height: 40)
                        
                    }
                    .padding(.bottom,8)
                    .onTapGesture {
                        isYukiShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isYukiShow){
                        Yuki()
                    }
                    
                    Divider()
                    
                    VStack{
                        ZStack{
                            Rectangle()
                                .fill(.green.opacity(0.5))
                                .frame(width: screenWidth * 0.9,height: 140)
                                .cornerRadius(24)
                            
                            HStack{
                                
                                Image("warasiicon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.24) // サイズ調整
                                    .padding(.leading,20)
                                
                                Text("座敷童子")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                            }
                            
                        }
                        HStack{
                            VStack{
                                Text("【東北の古い家】")
                                    .font(.headline)
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Capsule()
                                .stroke(Color.black.opacity(0.6),lineWidth: 1)
                                .frame(width: screenWidth * 0.24, height: screenWidth * 0.08)
                            .overlay(
                                Text("座敷童子")
                                    .padding()
                                    .foregroundStyle(Color.black.opacity(0.5))
                                    .fontWeight(.bold)
                                    .font(.callout)
                            )
                           
                        }
                        .frame(width: screenWidth * 0.86 , height: 40)
                        
                    }
                    .padding(.vertical,16)
                    .onTapGesture {
                        isWarasiShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isWarasiShow){
                        Zasikiwarasi()
                    }
                    
                    
                    
                    Divider()
                    
                    VStack{
                        ZStack{
                            Rectangle()
                                .fill(.pink.opacity(0.5))
                                .frame(width: screenWidth * 0.9,height: 140)
                                .cornerRadius(24)
                            
                            HStack{
                                    
                            
                                Image("noppe")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.24) // サイズ調整
                                    .padding(.leading,20)
                                
                                Text("おいてけぼり")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                
                            }
                            
                        }
                        HStack{
                            VStack{
                                Text("【博打にのめり込む男】")
                                    .font(.headline)
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Capsule()
                                .stroke(Color.black.opacity(0.6),lineWidth: 1)
                                .frame(width: screenWidth * 0.32, height: screenWidth * 0.08)
                            .overlay(
                                Text("のっぺらぼう")
                                    .padding()
                                    .foregroundStyle(Color.black.opacity(0.5))
                                    .fontWeight(.bold)
                                    .font(.callout)
                            )
                           
                        }
                        .frame(width: screenWidth * 0.86 , height: 40)
                        
                    }
                    .padding(.vertical,16)
                    .onTapGesture {
                        isOitekeShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isOitekeShow){
                        Oiteke()
                    }
                    
                    
                    Divider()
                    
                    
                    VStack{
                        ZStack{
                            Rectangle()
                                .fill(.orange.opacity(0.5))
                                .frame(width: screenWidth * 0.9,height: 140)
                                .cornerRadius(24)
                            
                            HStack{
                                Text("安珍清姫")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                             
                                Image("kiyohime")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.24) // サイズ調整
                                    .padding(.leading,20)
                            }
                            
                        }
                        HStack{
                            VStack{
                                Text("【若き僧と清姫との出会い】")
                                    .font(.headline)
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Capsule()
                                .stroke(Color.black.opacity(0.6),lineWidth: 1)
                                .frame(width: screenWidth * 0.24, height: screenWidth * 0.08)
                            .overlay(
                                Text("安珍清姫")
                                    .padding()
                                    .foregroundStyle(Color.black.opacity(0.6))
                                    .fontWeight(.bold)
                                    .font(.callout)
                            )
                           
                        }
                        .frame(width: screenWidth * 0.86 , height: 48)
                        
                    }
                    .padding(.vertical,16)
                    .onTapGesture {
                        isKiyohimeShow.toggle()
                    }
                    .fullScreenCover(isPresented: $isKiyohimeShow ){
                        Kiyohime()
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
