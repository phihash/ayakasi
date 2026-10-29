import SwiftUI
import Kingfisher

/// 妖怪の画像を角丸正方形で出す(ゆかりの地のカード・コメント一覧で共用)。画像が無ければ「？」
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
