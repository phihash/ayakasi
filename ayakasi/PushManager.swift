import UIKit
import FirebaseMessaging
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        // 権限リクエスト（起動時。opt-in率を上げたいなら価値を見せた後に移してもOK）
        requestPushAuthorization()
        return true
    }

    /// 通知許可 → APNs 登録
    func requestPushAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
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
        // 例: if let id = userInfo["documentId"] as? String { DeepLinkRouter へ }
    }
}
