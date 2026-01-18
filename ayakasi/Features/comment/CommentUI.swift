import SwiftUI

struct CommentUI: View {
    @EnvironmentObject var commentStore: CommentService
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var commentText = ""
    @Binding var isPresented: Bool
    let yokai : Ayakasi
    var body: some View {
        VStack(spacing: 20) {
            if authVM.user != nil {
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
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextFieldFocused ? Color.orange : Color.clear, lineWidth: 2)
                    )
                }
                .padding(.horizontal, 20)
                
                // 投稿ボタン
                Button(action: { // 投稿処理
                    print("🔘 投稿ボタン押下")
                    Task {
                        do {
                            try await commentStore.postComment(content: commentText, yokai: yokai)
                            print("🔄 fetchYokaiComments呼び出し")
                            await commentStore.fetchYokaiComments(yokaiId: yokai.documentId)
                            print("🏁 投稿処理完了")
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
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                
                Spacer()
            } else {
                Spacer()

                Text("ログインが必要です")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text("コメントを投稿するにはログインまたは新規登録してください")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Button {
                        isPresented = false
                        authVM.showLogin()
                    } label: {
                        Text("ログイン")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }

                    Button {
                        isPresented = false
                        authVM.showRegister()
                    } label: {
                        Text("新規登録")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

            }
        }
        .onTapGesture {
            if authVM.user != nil {
                isTextFieldFocused = false
            }
        }
        .alert("エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}
