import SwiftUI

struct FullScreenImage: View {
    @Environment(\.dismiss) private var dismiss
    let screenWidth = UIScreen.main.bounds.width
    let imageName : String
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            
            Group{
                if let url = URL(string: imageName) , url.scheme?.hasPrefix("http") == true{
                    AsyncImage(url:url){ phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Image("loading")
                                    .resizable()
                                    .scaledToFit()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            // 失敗時
                            ZStack {
                                Color.gray.opacity(0.15)
                                Image(systemName: "photo")
                                    .imageScale(.large)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                    }
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


