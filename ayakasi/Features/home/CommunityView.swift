import SwiftUI
import os

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            CommentFeedView()
                .background(Color.appBackground)
                .navigationTitle("コメント")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Ayakasi.self) { yokai in
                    NeoDetail(yokai: yokai, source: "comment")
                }
        }
    }
}

struct CommentFeedView: View {
    @EnvironmentObject var commentService: CommentService
    @State private var comments: [YokaiComment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            if isLoading && comments.isEmpty {
                ProgressView("読み込み中…")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
            } else if let errorMessage, comments.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, 80)
            } else if comments.isEmpty {
                CommentEmptyState()
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(comments) { comment in
                        CommentCard(comment: comment, showsYokai: true, onChanged: load)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
        .task { await load() }
        // Taskで包むのは、refreshableのタスクが引っ張り終わりの再描画で取り消され、通信が-999(cancelled)で失敗するため
        .refreshable { await Task { await load() }.value }
    }

    private func load() async {
        defer { isLoading = false }
        do {
            comments = try await commentService.fetchComments()
            errorMessage = nil
        } catch {
            Logger.comment.error("コメント一覧の取得に失敗: \(String(describing: error))")
            errorMessage = "読み込みに失敗しました"
        }
    }
}
