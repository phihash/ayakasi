import AmplitudeUnified

let amplitude = Amplitude(
    apiKey: Bundle.main.object(forInfoDictionaryKey: "AMPLITUDE_API_KEY") as? String ?? "",
    logger: ConsoleLogger(logLevel: LogLevelEnum.off.rawValue)
)

enum Analytics {
    static func trackYokaiViewed(name: String, documentId: String) {
        amplitude.track(eventType:"yokai_viewed", eventProperties: [
            "yokai_name": name,
            "document_id": documentId
        ])
    }

    static func trackMapSpotTapped(spotName: String, prefecture: String) {
        amplitude.track(eventType:"map_spot_tapped", eventProperties: [
            "spot_name": spotName,
            "prefecture": prefecture
        ])
    }

    static func trackEventLinkTapped(title: String, link: String) {
        amplitude.track(eventType:"event_link_tapped", eventProperties: [
            "event_title": title,
            "event_link": link
        ])
    }

    static func trackSearch(keyword: String) {
        amplitude.track(eventType:"search", eventProperties: [
            "keyword": keyword
        ])
    }

    // 画面表示（page view相当）
    static func trackScreenView(screenName: String) {
        amplitude.track(eventType: "screen_view", eventProperties: [
            "screen_name": screenName
        ])
    }

    // タブ切り替え
    static func trackTabChanged(tabName: String) {
        amplitude.track(eventType: "tab_changed", eventProperties: [
            "tab_name": tabName
        ])
    }

    // お気に入り登録/解除
    static func trackFavoriteToggled(yokaiName: String, documentId: String, isFavorite: Bool) {
        amplitude.track(eventType: "favorite_toggled", eventProperties: [
            "yokai_name": yokaiName,
            "document_id": documentId,
            "is_favorite": isFavorite
        ])
    }

    // コメント投稿
    static func trackCommentPosted(documentId: String) {
        amplitude.track(eventType: "comment_posted", eventProperties: [
            "document_id": documentId
        ])
    }

    // 投票
    static func trackVoted(yokaiName: String, documentId: String) {
        amplitude.track(eventType: "voted", eventProperties: [
            "yokai_name": yokaiName,
            "document_id": documentId
        ])
    }

    // カテゴリ選択
    static func trackCategorySelected(category: String) {
        amplitude.track(eventType: "category_selected", eventProperties: [
            "category": category
        ])
    }

    // 満足度アラート回答
    static func trackSatisfactionResponse(response: String) {
        amplitude.track(eventType: "satisfaction_response", eventProperties: [
            "response": response
        ])
    }

    // シェア
    static func trackAppShared() {
        amplitude.track(eventType: "app_shared")
    }
}
