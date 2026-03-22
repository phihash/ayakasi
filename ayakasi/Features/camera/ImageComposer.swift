import UIKit
import SwiftUI

struct ImageComposer {
    static func compose(
        background: UIImage,
        overlay: UIImage,
        at position: CGPoint,
        scale: CGFloat,
        rotation: Angle
    ) -> UIImage {
        let backgroundSize = background.size

        // 描画コンテキストを作成
        UIGraphicsBeginImageContextWithOptions(backgroundSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return background
        }

        // 背景画像を描画
        background.draw(at: .zero)

        // 妖怪画像のサイズを計算
        let overlaySize = CGSize(
            width: 200 * scale,
            height: 200 * scale
        )

        // 座標変換を適用（回転と配置）
        context.saveGState()

        // 位置を移動
        context.translateBy(x: position.x, y: position.y)

        // 回転を適用
        context.rotate(by: CGFloat(rotation.radians))

        // 妖怪画像を描画（中心を基準に）
        let drawRect = CGRect(
            x: -overlaySize.width / 2,
            y: -overlaySize.height / 2,
            width: overlaySize.width,
            height: overlaySize.height
        )
        overlay.draw(in: drawRect)

        context.restoreGState()

        // 合成画像を取得
        guard let composedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return background
        }

        return composedImage
    }

    // サイズを直接指定するバージョン
    static func composeWithSize(
        background: UIImage,
        overlay: UIImage,
        at position: CGPoint,
        size: CGFloat
    ) -> UIImage {
        let backgroundSize = background.size

        // 描画コンテキストを作成
        UIGraphicsBeginImageContextWithOptions(backgroundSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return background
        }

        // 背景画像を描画
        background.draw(at: .zero)

        // 妖怪画像のサイズ
        let overlaySize = CGSize(width: size, height: size)

        // 座標変換を適用
        context.saveGState()

        // 位置を移動
        context.translateBy(x: position.x, y: position.y)

        // 妖怪画像を描画（中心を基準に）
        let drawRect = CGRect(
            x: -overlaySize.width / 2,
            y: -overlaySize.height / 2,
            width: overlaySize.width,
            height: overlaySize.height
        )
        overlay.draw(in: drawRect)

        context.restoreGState()

        // 合成画像を取得
        guard let composedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return background
        }

        return composedImage
    }
}

