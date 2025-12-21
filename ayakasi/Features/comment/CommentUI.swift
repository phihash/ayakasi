import SwiftUI

struct CommentUI: View {
    @EnvironmentObject var commentStore: CommentService
    @FocusState private var isTextFieldFocused: Bool
    let yokai : Ayakasi
    var body: some View {
        VStack(spacing: 20) {
                Text("コメントを投稿")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // カスタムテキストフィールド
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("コメントを入力してください...", text: $commentStore.commentNow, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .lineLimit(3...6)
                            .font(.body)
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextFieldFocused ? Color.orange : Color.clear, lineWidth: 2)
                    )
                }
                .padding(.horizontal, 20)
                
                // 投稿ボタン
                Button(action: {
                    // 投稿処理
                    Task {
                        await commentStore.postComment(yokai: yokai)
                    }
                    isTextFieldFocused = false
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("投稿する")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.orange)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .disabled(commentStore.commentNow.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(commentStore.commentNow.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                
                Spacer()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}
