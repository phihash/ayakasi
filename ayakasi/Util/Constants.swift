import Foundation

struct AppConstants {
    static let contactFormURL = "https://forms.gle/3e4DGw8CPY3VrJTJ9"
    static let termsOfServiceURL = "https://sizu.me/maili/posts/ae75vb8z0sso"
    static let privacyPolicyURL = "https://sizu.me/maili/posts/b3at3db2i5f1"
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

