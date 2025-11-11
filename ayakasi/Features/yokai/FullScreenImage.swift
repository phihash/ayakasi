import SwiftUI
import Kingfisher

struct FullScreenImage: View {
    @Environment(\.dismiss) private var dismiss
    let screenWidth = UIScreen.main.bounds.width
    let imageName : String
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            
            Group{
                if let url = URL(string: imageName) , url.scheme?.hasPrefix("http") == true{
                    KFImage(url)
                        .placeholder {
                            Image("loading")
                                .resizable()
                                .scaledToFit()
                        }
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFit()
                }else{
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                }
                
            }
            
            VStack{
                HStack{
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: screenWidth * 0.1, height: screenWidth * 0.1)
                        .overlay(
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                                .padding()
                        )
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(.trailing,18)
                }
                Spacer()
            }
        }
    }
}


