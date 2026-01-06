import SwiftUI
import Kingfisher

struct EventItem: Codable {
    let title: String?
    let link: String?
    let imageUrl: String?
    let startDateTime: String?
    let endDateTime: String?
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
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                KFImage(imageUrl.flatMap { URL(string: $0) })
                    .placeholder {
                        Image("loading_banner")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            
                VStack {
                    Spacer()
                    HStack {
                        Text(linkTitle)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                        Spacer()
                    }
                    .padding(.leading, 24)
                    .padding(.bottom, 52)
                }
            }
            .frame(width: screenWidth * 0.9, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
