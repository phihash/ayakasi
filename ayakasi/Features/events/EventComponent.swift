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
            VStack(spacing: 12) {
                KFImage(imageUrl.flatMap { URL(string: $0) })
                    .placeholder {
                        Image("loading_banner")
                            .resizable()
                            .scaledToFill()
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth * 0.9 - 24, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(linkTitle)
                            .font(.headline)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Text(location ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)
            .frame(width: screenWidth * 0.9)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.bottom, 20)
        }
    }
}
