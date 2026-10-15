import Foundation
import UserNotifications

/// 孵化などのローカル通知をスケジュールする。
enum NotificationScheduler {
    /// 新たに孵化した妖怪ごとに「うまれた！」通知を出す（通知許可済みのときだけ）。
    /// タップすると既存の通知タップ処理（AppDelegate）が図鑑詳細へ誘導する。
    static func scheduleHatchNotifications(_ records: [GrowthStore.HatchRecord]) async {
        guard !records.isEmpty else { return }
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional else { return }

        for record in records {
            guard let yokai = ayakasis.first(where: { $0.documentId == record.documentId }) else { continue }
            let content = UNMutableNotificationContent()
            content.title = "🎉 妖怪がうまれた！"
            content.body = "「\(yokai.name)」がうまれました。タップして図鑑を見る"
            content.sound = .default
            content.userInfo = ["documentId": record.documentId] // 既存のタップ処理が消化する
            let request = UNNotificationRequest(identifier: "hatch-\(record.id)",
                                                content: content,
                                                trigger: nil) // すぐ配信
            try? await center.add(request)
        }
    }
}
