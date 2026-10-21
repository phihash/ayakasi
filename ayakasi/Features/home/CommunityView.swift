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
                NeoDetail(yokai: yokai)
            }
        }
    }
}

struct CommentFeedView: View {
    @Binding var selectedYokai: Ayakasi?
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var commentService: CommentService
    @State private var isPickingYokai = false
    @State private var showLoginAlert = false
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
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(comments) { comment in
                        row(comment)
                        Divider().padding(.horizontal, 20)
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                if authVM.authStatus == .authenticated {
                    isPickingYokai = true
                } else {
                    showLoginAlert = true
                }
            } label: {
                ActionCircleIcon(assetName: "forum")
            }
            .accessibilityLabel("コメント")
            .padding(.trailing, 22)
            .padding(.bottom, 14)
        }
        .alert("ログインが必要です", isPresented: $showLoginAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("コメントを投稿するには、設定画面からログインまたは新規登録してください。")
        }
        // コメントは妖怪ごとなので、先に妖怪を選んでから書く
        .sheet(isPresented: $isPickingYokai, onDismiss: { Task { await load() } }) {
            CommentTargetPicker(isPresented: $isPickingYokai)
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
                    .padding(.top, 8)
                    .padding(.trailing, 8)
            }
        }
    }

    private func rowButton(_ comment: YokaiComment, yokai: Ayakasi?) -> some View {
        Button {
            selectedYokai = yokai
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(yokai?.name ?? comment.yokaiId)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appPrimary)
                    if comment.isWithdrawn {
                        Text("退会したユーザー")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                    Text(DateFormatter.shortDateTime.string(from: comment.createdAt))
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Text(comment.content)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
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

/// コメントのタブから書くときの、妖怪選び → コメント入力
private struct CommentTargetPicker: View {
    @Binding var isPresented: Bool
    @State private var target: Ayakasi?

    var body: some View {
        NavigationStack {
            YokaiSearchView { yokai in target = yokai }
                .navigationDestination(item: $target) { yokai in
                    CommentUI(isPresented: $isPresented, yokai: yokai)
                        .navigationTitle(yokai.name)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { isPresented = false }
                    }
                }
        }
    }
}
