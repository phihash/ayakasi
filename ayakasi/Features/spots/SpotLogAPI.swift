#if DEBUG
import Foundation

struct SpotLog: Decodable, Identifiable {
    let id: Int
    let yokaiId: String
    let spotName: String
    let prefecture: String
    let createdAt: Date
    let body: String
    let photoCount: Int
    let isMine: Bool
    let isWithdrawn: Bool

    var byline: String {
        if isWithdrawn { return "退会したユーザー" }
        return isMine ? "自分" : "訪問者"
    }
    var photoURLs: [URL] {
        (0..<min(max(0, photoCount), SpotLogAPI.maxPhotos)).map { index in
            SpotLogAPI.endpoint.appending(path: "\(id)/photo")
                .appending(queryItems: [URLQueryItem(name: "index", value: String(index))])
        }
    }
}

struct SpotLogSubmission: Encodable {
    let requestId: UUID
    let yokaiId: String
    let spotName: String
    let prefecture: String
    let body: String
    let photos: [Data]
}

enum SpotLogAPI {
    static var endpoint: URL {
        #if targetEnvironment(simulator)
        // Xcodeからの通常起動でも試作のWorkerに接続する。-useLocalSpotLogs NO で公開版を確認できる。
        if UserDefaults.standard.object(forKey: "useLocalSpotLogs") == nil || UserDefaults.standard.bool(forKey: "useLocalSpotLogs") {
            return URL(string: "http://127.0.0.1:8791/spot-logs")!
        }
        #endif
        return URL(string: AppConstants.spotLogsDataURL)!
    }

    static let maxPhotos = 4

    @MainActor
    static func list(yokaiId: String, spot: YokaiSpot? = nil) async throws -> [SpotLog] {
        var query = [URLQueryItem(name: "yokaiId", value: yokaiId)]
        if let spot {
            query += [URLQueryItem(name: "spotName", value: spot.spotName),
                      URLQueryItem(name: "prefecture", value: spot.prefecture)]
        }
        let url = endpoint.appending(queryItems: query)
        let auth = AuthService.shared
        let request = auth.currentUser == nil ? URLRequest(url: url) : try await auth.authorizedRequest(url, forceRefresh: false)
        return try await send(request)
    }

    static func publish(_ visit: SpotLogSubmission) async throws -> SpotLog {
        var request = try await AuthService.shared.authorizedRequest(endpoint, forceRefresh: true)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        request.httpBody = try encoder.encode(visit)
        return try await send(request)
    }

    private static func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode
        switch code {
        case 200, 201:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { value in
                let text = try value.singleValueContainer().decode(String.self)
                return try Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
            }
            return try decoder.decode(T.self, from: data)
        case 401: throw VisitError("ログインし直してください。")
        case 403: throw VisitError("メールアドレスを確認してから投稿してください。")
        case 404: throw VisitError("訪問記のAPIが見つかりません（HTTP 404）。")
        case 400: throw VisitError("本文と添付写真を確認してください。")
        case 413: throw VisitError("写真のサイズが大きすぎます。写真を選び直してください。")
        case 422: throw VisitError("この場所はゆかりの地から変更されました。訪問先を確認してください。")
        case 429: throw VisitError("投稿が続いています。少し時間をおいてお試しください。")
        default:
            if let code { throw VisitError("訪問記のサーバーからエラーが返りました（HTTP \(code)）。") }
            throw VisitError("訪問記のサービスに接続できませんでした。")
        }
    }
}

struct VisitError: LocalizedError {
    let errorDescription: String?
    init(_ message: String) { errorDescription = message }
}
#endif
