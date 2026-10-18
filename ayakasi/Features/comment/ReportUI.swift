import SwiftUI

/// コメントの「…」メニュー(通報・ブロック)。Appleの審査ガイドライン1.2で必須。自分のコメントには付けない
struct CommentMenu: View {
    let comment: YokaiComment
    /// 通報・ブロックしたコメントはWorkerが本人に返さなくなるので、終わったら一覧を取り直してもらう
    let onDone: () async -> Void
    @EnvironmentObject var commentService: CommentService
    @State private var showReportConfirmation = false
    @State private var showBlockConfirmation = false
    @State private var errorMessage: String?

    var body: some View {
        Menu {
            Button("コメントを報告する", systemImage: "exclamationmark.triangle", role: .destructive) {
                showReportConfirmation = true
            }
            Button("ユーザーをブロックする", systemImage: "person.fill.xmark", role: .destructive) {
                showBlockConfirmation = true
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("コメントのメニュー")
        .confirmationDialog("コメントを報告しますか？", isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button("報告する", role: .destructive) { run { try await commentService.report(comment) } }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("不適切なコメントとして報告します。報告したコメントは表示されなくなります。")
        }
        .confirmationDialog("ユーザーをブロックしますか？", isPresented: $showBlockConfirmation, titleVisibility: .visible) {
            Button("ブロックする", role: .destructive) { run { try await commentService.blockAuthor(of: comment) } }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("このユーザーのコメントは表示されなくなります。")
        }
        .alert("エラー", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // 成功の知らせを出さないのは、コメントが一覧から消えることで伝わるため
    private func run(_ action: @escaping () async throws -> Void) {
        Task {
            do {
                try await action()
                await onDone()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
