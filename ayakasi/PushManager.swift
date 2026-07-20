import UIKit
import SwiftUI
import FirebaseMessaging
import UserNotifications

/// 通知タップからの遷移先を保持する共有ルーター
@MainActor
final class DeepLinkRouter: ObservableObject {
    static let shared = DeepLinkRouter()
    /// タップされた妖怪の documentId（消化したら nil に戻す）
    @Published var pendingYokaiId: String?
    /// タップされたイベントのURL（消化したら nil に戻す）
    @Published var pendingEventURL: URL?
    private init() {}
}

/// 通知許可まわり。プロンプトを出す場所と、起動時の再登録を分離する。
enum PushAuthorization {
    /// 既に許可済みのときだけ APNs 登録する（プロンプトは出さない）。起動時に呼ぶ。
    static func registerIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    /// 未決定のときだけ許可プロンプトを出す。イベントタブ表示など文脈のある場所で呼ぶ。
    static func requestIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        // 許可プロンプトはイベントタブ表示時に出す（PushAuthorization.requestIfNeeded）。
        // 起動時は「既に許可済みならAPNs登録だけ」してトークンを新鮮に保つ。
        PushAuthorization.registerIfAuthorized()
        return true
    }

    // APNs トークンを FCM に橋渡し
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[Push] APNs 登録失敗:", error)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // ↓ テスト送信で使うトークン。Xcodeのログからコピーする
        print("[Push] FCM token:", fcmToken ?? "nil")

        #if DEBUG
        // 開発ビルドはテスト用トピックに入れる（誤爆防止）
        Messaging.messaging().subscribe(toTopic: "test")
        #else
        // 本番ビルドは全体配信トピック
        Messaging.messaging().subscribe(toTopic: "all")
        #endif
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // フォアグラウンドでも通知を表示
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }

    // 通知タップ時（将来ここで妖怪詳細へ deep link できる）
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        print("[Push] tapped:", userInfo)
        if let id = userInfo["documentId"] as? String {
            await MainActor.run { DeepLinkRouter.shared.pendingYokaiId = id }
        } else if let urlString = userInfo["url"] as? String,
                  let url = URL(string: urlString) {
            await MainActor.run { DeepLinkRouter.shared.pendingEventURL = url }
        }
    }
}
