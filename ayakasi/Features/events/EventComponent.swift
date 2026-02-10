import SwiftUI
import Kingfisher

struct EventItem: Codable {
    let title: String?
    let link: String?
    let imageUrl: String?
    let startDateTime: String?
    let endDateTime: String?
    let location: String?
    let isActive: Bool?
    let minVersion: String?
    let maxVersion: String?
    let bannerType: String?
}

struct NoticeItem: Codable {
    let message: String
    let isActive: Bool
    let startDateTime: String?
    let endDateTime: String?
}

struct EventComponent: View {
    @State private var ogImage: Image?
    let screenWidth = UIScreen.main.bounds.width
    let link : String
    let linkTitle : String
    let imageUrl : String?
    let location : String?
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 0) {
                KFImage(imageUrl.flatMap { URL(string: $0) })
                    .placeholder {
                        Image("loading_banner")
                            .resizable()
                            .scaledToFill()
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth * 0.9, height: 180)
                    .clipped()

                HStack {
                    VStack{
                        Text(linkTitle)
                            .font(.headline)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Text(location ?? "")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                    }
                  
                    Spacer()
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(.white)
            }
            .frame(width: screenWidth * 0.9)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}
