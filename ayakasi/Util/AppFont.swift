import SwiftUI

/// 設定画面で選べる書体
// ttfを同梱しないのは、どれもiOSに入っているヒラギノで足り、和文フォントは1書体で数MB以上あるため
enum AppFontChoice: String, CaseIterable, Identifiable {
    case standard, mincho, maru
    static let storageKey = "appFontChoice"
    var id: String { rawValue }

    var label: String {
        switch self {
        case .standard: return "標準(ゴシック)"
        case .mincho: return "明朝"
        case .maru: return "丸ゴシック"
        }
    }

    // 標準は .system のまま返す。Font.custom で角ゴを名指しすると欧文までヒラギノになり、今の見た目が変わるため
    func font(_ style: Font.TextStyle, weight: Font.Weight?) -> Font {
        // .headline は .system だと元から太字なので、名指しの書体でもそろえる
        let weight = weight ?? (style == .headline ? .semibold : nil)
        switch self {
        case .standard:
            return weight.map { .system(style).weight($0) } ?? .system(style)
        case .mincho:
            // ヒラギノ明朝はW3とW6しか無いので、太字指定はW6に寄せる
            let isBold = weight.map { [.semibold, .bold, .heavy, .black].contains($0) } ?? false
            return .custom(isBold ? "HiraMinProN-W6" : "HiraMinProN-W3", size: Self.size(style), relativeTo: style)
        case .maru:
            // ヒラギノ丸ゴはW4だけ。太さを合成すると字が潰れるので、太字指定は無視する
            return .custom("HiraMaruProN-W4", size: Self.size(style), relativeTo: style)
        }
    }

    // 文字サイズ「標準」のときの各スタイルの大きさ(Apple HIG)。relativeTo でDynamic Typeに追従する
    private static func size(_ style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline, .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        default: return 17
        }
    }
}

private struct AppFontModifier: ViewModifier {
    @AppStorage(AppFontChoice.storageKey) private var choice: AppFontChoice = .standard
    let style: Font.TextStyle
    let weight: Font.Weight?

    func body(content: Content) -> some View {
        content.font(choice.font(style, weight: weight))
    }
}

extension View {
    /// .font(.subheadline) の代わり。設定で選んだ書体で表示する
    func appFont(_ style: Font.TextStyle, weight: Font.Weight? = nil) -> some View {
        modifier(AppFontModifier(style: style, weight: weight))
    }
}
