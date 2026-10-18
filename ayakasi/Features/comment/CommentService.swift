import Foundation
import SwiftUI
import os

struct CommentError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

/// Worker の GET /comments が返す1件。投稿者のuidは返ってこない(isMineで自分のものか分かる)
struct YokaiComment: Decodable, Identifiable {
    let id: Int
    let yokaiId: String
    let content: String
    let createdAt: Date
    let isWithdrawn: Bool
    let isMine: Bool

    static func decodeList(from data: Data) throws -> [YokaiComment] {
        let decoder = JSONDecoder()
        // .iso8601にしないのは、D1の日時がミリ秒付き(…:27.606Z)で、.iso8601はミリ秒を読めないため
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            return try Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
        }
        return try decoder.decode([YokaiComment].self, from: data)
    }
}

@MainActor
class CommentService : ObservableObject {
    private let authService: AuthServiceProtocol
    private let commentTokenBucket: TokenBucketProtocol

    init(authService: AuthServiceProtocol, tokenBucket: TokenBucketProtocol) {
        self.authService = authService
        self.commentTokenBucket = tokenBucket
    }

    // 妖怪ごとに持つのは、詳細A→関連妖怪Bの詳細→戻る、でAの画面にBのコメントが残るため(戻ってもAの.taskは走り直さない)
    @Published var yokaiComments: [String: [YokaiComment]] = [:]

    /// コメント一覧。ログイン中はトークンを付けて、自分のコメントか(isMine)も受け取る
    func fetchComments(yokaiId: String? = nil) async throws -> [YokaiComment] {
        var components = URLComponents(string: AppConstants.commentsDataURL)!
        if let yokaiId { components.queryItems = [URLQueryItem(name: "yokaiId", value: yokaiId)] }
        let url = components.url!
        let request = authService.currentUser == nil
            ? URLRequest(url: url)
            : try await authService.authorizedRequest(url, forceRefresh: false)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try YokaiComment.decodeList(from: data)
    }

    func fetchYokaiComments(yokaiId: String) async {
        do {
            yokaiComments[yokaiId] = try await fetchComments(yokaiId: yokaiId)
        } catch {
            Logger.comment.error("fetchYokaiComments(\(yokaiId))失敗: \(String(describing: error))")
        }
    }

    // FirestoreのルールとD1のCHECKと同じ上限
    static let maxLength = 500

    // String.countで数えないのは、絵文字(👨‍👩‍👧など)を1字と数えてしまい、SQLiteのlength()より少なく出るため
    static func length(of content: String) -> Int { content.unicodeScalars.count }

    func postComment(content: String, yokai: Ayakasi) async throws {
        guard !content.isEmpty else {
            throw CommentError(message: "コメントが空です")
        }
        guard Self.length(of: content) <= Self.maxLength else {
            throw CommentError(message: "コメントは\(Self.maxLength)文字以内で入力してください")
        }
        guard let user = authService.currentUser, user.isEmailVerified else {
            throw CommentError(message: "ログインが必要です")
        }
        guard commentTokenBucket.canConsume() else {
            throw CommentError(message: "コメント回数の上限に達しました。しばらく待って再度お試しください。")
        }

        // トークンを取り直すのは、メール認証した直後だと手元のトークンがまだ「未認証」のままで、Workerに403で弾かれるため
        var request = try await authService.authorizedRequest(URL(string: AppConstants.commentsDataURL)!, forceRefresh: true)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["yokaiId": yokai.documentId, "content": content])

        let (_, response) = try await URLSession.shared.data(for: request)
        switch (response as? HTTPURLResponse)?.statusCode {
        case 201:
            commentTokenBucket.consume()
        case 403:
            throw CommentError(message: "メールアドレスの確認が済んでいません")
        case 429:
            throw CommentError(message: "コメント回数の上限に達しました。しばらく待って再度お試しください。")
        default:
            throw CommentError(message: "コメントを投稿できませんでした")
        }
    }

    func report(_ comment: YokaiComment) async throws {
        try await sendAction("report", to: comment)
    }

    /// 投稿者のuidは手元にないので、コメントidで「このコメントを書いた人」をブロックする
    func blockAuthor(of comment: YokaiComment) async throws {
        try await sendAction("block", to: comment)
    }

    private func sendAction(_ action: String, to comment: YokaiComment) async throws {
        guard let user = authService.currentUser, user.isEmailVerified else {
            throw CommentError(message: "通報・ブロックするには、設定画面からログインしてください")
        }
        // 投稿と同じく、メール認証した直後の「未認証」のトークンで403にならないよう取り直す
        var request = try await authService.authorizedRequest(
            URL(string: "\(AppConstants.commentsDataURL)/\(comment.id)/\(action)")!, forceRefresh: true)
        request.httpMethod = "POST"
        let (_, response) = try await URLSession.shared.data(for: request)
        switch (response as? HTTPURLResponse)?.statusCode {
        case 204: return
        case 403: throw CommentError(message: "メールアドレスの確認が済んでいません")
        default: throw CommentError(message: "送信できませんでした。しばらくしてからもう一度お試しください")
        }
    }
}
