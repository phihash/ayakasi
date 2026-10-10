import Foundation

struct AppConstants {
    static let contactFormURL = "https://forms.gle/3e4DGw8CPY3VrJTJ9"
    static let termsOfServiceURL = "https://sizu.me/maili/posts/ae75vb8z0sso"
    static let privacyPolicyURL = "https://sizu.me/maili/posts/b3at3db2i5f1"
    static let events2DataURL = "https://yokai-images.insharp0220.workers.dev/events"
    static let noticeDataURL = "https://raw.githubusercontent.com/phihash/JSON/refs/heads/main/notice.json"
}

struct YokaiCategories {
    static let searchCategories = ["鳥山石燕","道の怪", "水の怪","音の怪","都市伝説","家の怪","動物の怪","山の怪","外国の妖怪","詳細不明","怨霊"]
    static let allCategories = ["すべて"] + searchCategories

    static let popularLabel = "よく見られている"
    // ponytail: 手動キュレーション。実アクセス数で並べたいならAmplitude/D1で集計して差し替え
    static let popularNames = ["豆腐小僧", "うみぼうず", "崇徳天皇", "胴面", "絹狸", "あかなめ"]
}

extension Bundle {
    var appName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "App"
    }
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
    var buildNumber: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }
}

