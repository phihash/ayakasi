import SwiftUI
import Kingfisher

// ニュース・イベントのカード。画像(リンク先のog:image)は横幅いっぱいに出し、
// 無いカードは同じ枠にタイトルを大きく描く(文字だけのカードが混ざると、画像のある記事との差で一覧が凸凹するため)
struct ListCard<Content: View>: View {
    let image: URL?
    let systemImage: String
    let title: String
    let phrases: [String]?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // og:imageの推奨比率(1200x630)。比率を固定しないと、画像ごとにカードの高さがばらつく
            Color.appTextSecondary.opacity(0.08)
                .aspectRatio(1.91, contentMode: .fit)
                .overlay {
                    if let image {
                        KFImage(image)
                            .placeholder {
                                // 外部からの読み込みを断るサイトもあるので、失敗してもアイコンで枠を埋める
                                Image(systemName: systemImage)
                                    .font(.title2)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .downsampling(size: CGSize(width: 400, height: 210))
                            .scaleFactor(UIScreen.main.scale)
                            .resizable()
                            .scaledToFill()
                    } else {
                        TitleArt(title: title, phrases: phrases)
                    }
                }
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                // 画像の無いカードはタイトルを上に描いたので、ここで繰り返さない
                if image != nil {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                content
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

// og:imageの無い記事・イベントの代わりの絵(noteの自動生成OGPと同じ考え方)。
// 画像ファイルを作らずその場で描くのは、文字の縮小・省略・カーニングをiOSの組版にそのまま任せられるため
private struct TitleArt: View {
    let title: String
    let phrases: [String]?

    // ヒラギノを名指しするのは、システムフォントだと和文がフォールバックになり、halt(約物の半角化)が掛からないため
    private static let font: Font = {
        let base = UIFont(name: "HiraginoSans-W7", size: 22) ?? .boldSystemFont(ofSize: 22)
        let halt = base.fontDescriptor.addingAttributes([.featureSettings: [[
            UIFontDescriptor.FeatureKey.type: kTextSpacingType,
            UIFontDescriptor.FeatureKey.selector: kAltHalfWidthTextSelector,
        ]]])
        return Font(UIFont(descriptor: halt, size: 22))
    }()

    // 文節(WorkerがBudouXで分けたもの)の中はWORD JOINERで改行を禁じ、文節の間だけゼロ幅スペースで改行を許す。
    // 古いWorkerの応答などでphrasesが無ければ、iOSの通常の改行に任せる
    private var text: String {
        guard let phrases else { return title }
        return phrases
            .map { $0.map(String.init).joined(separator: "\u{2060}") }
            .joined(separator: "\u{200B}")
    }

    var body: some View {
        Text(text)
            .font(Self.font)
            .foregroundStyle(.white)
            .lineSpacing(4)
            .lineLimit(4)
            .minimumScaleFactor(0.6)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(20)
            .background(LinearGradient(colors: [.appSecondary, .appAccent], startPoint: .topLeading, endPoint: .bottomTrailing))
            .accessibilityLabel(title)
    }
}
