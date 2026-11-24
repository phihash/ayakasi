import SwiftUI
import Kingfisher

/// ゆかりの地のカードに表示する妖怪のサムネイル。画像が無ければ「？」
struct YokaiThumbnail: View {
    let yokai: Ayakasi?
    var size: CGFloat = 88

    var body: some View {
        ZStack {
            Color.gray.opacity(0.12)
            if let yokai, yokai.imageName != "NoImage" {
                KFImage(URL(string: yokai.imageName))
                    .downsampling(size: CGSize(width: size, height: size))
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "questionmark.square")
                    .font(.system(size: size * 0.3))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
