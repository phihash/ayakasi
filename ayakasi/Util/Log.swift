import Foundation
import os

/// アプリ共通のロガー。printの代わりにこれを使う。
/// - デバッグ中はXcodeコンソールに出る。リリースでは補間値（\(...)）は自動で<private>に伏せられる。
/// - Console.appで `subsystem:net.phihash.ayakasi` で絞り込める。
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "net.phihash.ayakasi"

    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let push = Logger(subsystem: subsystem, category: "push")
    static let comment = Logger(subsystem: subsystem, category: "comment")
    static let web = Logger(subsystem: subsystem, category: "web")
    static let data = Logger(subsystem: subsystem, category: "data")
}
