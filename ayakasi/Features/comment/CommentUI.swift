import SwiftUI

struct CommentUI: View {
    @EnvironmentObject var commentStore: CommentService
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var commentText = ""
    @State private var isPosting = false
    @Binding var isPresented: Bool
    let yokai : Ayakasi

    private var commentLength: Int { CommentService.length(of: commentText) }
    private var isTooLong: Bool { commentLength > CommentService.maxLength }
    private var canPost: Bool {
        !isPosting && !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTooLong
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("コメントを投稿")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top, 20)

            // カスタムテキストフィールド
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("コメントを入力してください...", text: $commentText, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .lineLimit(3...6)
                            .font(.body)
                    }
                    .padding(16)
                    .background(Color.appTextSecondary.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextFieldFocused ? Color.appPrimary : Color.clear, lineWidth: 2)
                    )

                    Text("\(commentLength)/\(CommentService.maxLength)")
                        .font(.caption)
                        .foregroundStyle(isTooLong ? Color.red : Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                
                // 投稿ボタン
                Button(action: { // 投稿処理
                    guard canPost else { return }
                    isPosting = true
                    Task {
                        defer { isPosting = false }
                        do {
                            try await commentStore.postComment(content: commentText, yokai: yokai)
                            Analytics.trackCommentPosted(documentId: yokai.documentId)
                            await commentStore.fetchYokaiComments(yokaiId: yokai.documentId)
                            commentText = ""
                            isPresented = false
                        } catch {
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                    isTextFieldFocused = false
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text(isPosting ? "投稿中…" : "投稿する")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.appPrimary)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .disabled(!canPost)
                .opacity(canPost ? 1.0 : 0.5)

            Spacer()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .alert("エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}
