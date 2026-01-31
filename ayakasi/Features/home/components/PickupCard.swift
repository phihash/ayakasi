import SwiftUI
import Kingfisher

struct PickupCard: View {
    let ayakasi: Ayakasi
    @EnvironmentObject var voteService: VoteService
    
    @ViewBuilder
    private var nameOverlay: some View {
        Text(ayakasi.name)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
            .padding(.leading, 20)
            .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private var voteOverlay: some View {
        Capsule().fill(Color.red.opacity(0.9))
            .frame(width: 60, height: 30)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 1)
            .overlay(
                HStack {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.white)
                    Text("\(voteService.voteCountCache[ayakasi.documentId] ?? 0)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            )
            .padding(.leading, 8)
            .padding(.top, 8)
    }
    
    @ViewBuilder
    private var storyOverlay: some View {
        if ayakasi.sotry {
            Circle().fill(Color.black.opacity(0.6))
                .frame(width: 40, height: 40)
                .overlay(
                    Image("book")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                )
                .padding(.trailing, 8)
                .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private func networkImage(url: URL) -> some View {
        KFImage(url)
            .placeholder {
                Image("loading")
                    .resizable()
                    .scaledToFill()
            }
            .cacheOriginalImage()
            .resizable()
            .scaledToFill()
            .frame(width: 120)
            .cornerRadius(12)
            .overlay(alignment: .bottomLeading) { nameOverlay }
            .overlay(alignment: .topLeading) { voteOverlay }
            .overlay(alignment: .topTrailing) { storyOverlay }
    }
    
    @ViewBuilder
    private var localImage: some View {
        Image(ayakasi.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 120)
            .cornerRadius(12)
            .overlay(alignment: .bottomLeading) {
                Text(ayakasi.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
            }
    }
    
    var body: some View {
        ZStack {
            Group {
                if let url = URL(string: ayakasi.imageName), url.scheme?.hasPrefix("http") == true {
                    networkImage(url: url)
                } else {
                    localImage
                }
            }
        }
    }
}
