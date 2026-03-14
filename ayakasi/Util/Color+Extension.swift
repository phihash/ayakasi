//
//  Color+Extension.swift
//  ayakasi
//
//  カラーパレット定義
//  全てのカスタムカラーを一元管理
//

import SwiftUI

extension Color {
    // MARK: - Background Colors

    /// メイン背景色（温かみのあるオフホワイト）
    static let appBackground = Color(hex: "F0EEEA")

    /// カード背景色
    static let appCardBackground = Color.white

    /// テキストフィールド背景色（薄いグレー）
    static let appTextFieldBackground = Color(hex: "F2F2F7")

    // MARK: - Text Colors

    /// メインテキスト色
    static let appTextPrimary = Color(hex: "0F1420")

    /// セカンダリテキスト色（説明文、サブテキスト）
    static let appTextSecondary = Color(hex: "8E8E93")

    /// 白色テキスト
    static let appTextWhite = Color.white

    /// 黒色テキスト
    static let appTextBlack = Color.black

    // MARK: - Primary Action Colors

    /// メインCTAカラー（オレンジ）
    static let appPrimary = Color(hex: "ED9440")

    /// セカンダリアクションカラー（ブルー）
    static let appSecondary = Color(hex: "414CB4")

    // MARK: - Status Colors

    /// 成功・確認カラー（グリーン）
    static let appSuccess = Color(hex: "49B426")

    /// エラー・危険カラー（レッド）
    static let appError = Color(hex: "CF4938")

    // MARK: - Accent Colors

    /// お気に入り・ハイライトカラー（イエロー）
    static let appHighlight = Color(hex: "FFD60A")

    /// 補助アクセントカラー（パープル）
    static let appAccent = Color(hex: "BF5AF2")

    // MARK: - Game Colors (ゲーム用の色)

    /// ゲーム赤色
    static let gameRed = Color.red

    /// ゲーム青色
    static let gameBlue = Color.blue

    /// ゲーム黄色
    static let gameYellow = Color.yellow

    // MARK: - Story Section Colors (ストーリーセクション番号用)

    /// 雪女ストーリー用
    static let storyBlue = Color(hex: "414CB4")

    /// 清姫ストーリー用
    static let storyOrange = Color(hex: "ED9440")

    /// 追い手ストーリー用
    static let storyRed = Color(hex: "CF4938")

    /// 座敷童子ストーリー用
    static let storyGreen = Color(hex: "49B426")

    /// 山姥ストーリー用
    static let storyPurple = Color(hex: "BF5AF2")

    // MARK: - Hex Initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
