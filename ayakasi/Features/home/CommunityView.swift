import SwiftUI
import os

struct CommunityView: View {
    @State private var selectedYokai: Ayakasi?

    var body: some View {
        NavigationStack {
            CommentFeedView(selectedYokai: $selectedYokai)
            .background(Color.appBackground)
            .navigationTitle("コメント")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedYokai) { yokai in
                NeoDetail(yokai: yokai, source: "comment")
            }
        }
    }
}

struct CommentFeedView: View {
    @Binding var selectedYokai: Ayakasi?
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
                ContentUnavailableView("まだコメントがありません", systemImage: "bubble.left")
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(comments) { comment in
                        row(comment)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
        .task { await load() }
        // Taskで包むのは、refreshableのタスクが引っ張り終わりの再描画で取り消され、通信が-999(cancelled)で失敗するため
        .refreshable { await Task { await load() }.value }
    }

    private func row(_ comment: YokaiComment) -> some View {
        let yokai = yokaiById(comment.yokaiId)
        // メニューを行のButtonの外に置くのは、Buttonの中のMenuはタップが行の遷移に取られるため
        return HStack(alignment: .top, spacing: 0) {
            rowButton(comment, yokai: yokai)
            if !comment.isMine {
                CommentMenu(comment: comment) { await load() }
                    .padding(.top, 6)
                    .padding(.trailing, 6)
            }
        }
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appTextSecondary.opacity(0.15)))
    }

    private func rowButton(_ comment: YokaiComment, yokai: Ayakasi?) -> some View {
        Button {
            selectedYokai = yokai
        } label: {
            HStack(alignment: .center, spacing: 14) {
                YokaiThumbnail(yokai: yokai)
                VStack(alignment: .leading, spacing: 6) {
                    Text(comment.content)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    Text(([yokai?.name ?? comment.yokaiId, DateFormatter.shortDateTime.string(from: comment.createdAt)]
                          + (comment.isWithdrawn ? ["退会したユーザー"] : [])).joined(separator: " ・ "))
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(yokai == nil)
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
