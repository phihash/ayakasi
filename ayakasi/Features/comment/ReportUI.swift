import SwiftUI

struct ReportUI: View {
    @EnvironmentObject var commentService : CommentService
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var favoriteService: FavoriteService
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    let commentId: String
    let userId: String

    var body: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    do {
                        try await commentService.reportRecentComment(documentId: commentId)
                        alertTitle = "完了"
                        alertMessage = "報告が完了しました"
                        showAlert = true
                    } catch {
                        alertTitle = "エラー"
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                    Text("コメントを報告する")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, minHeight: 50)
                .background(.red)
                .cornerRadius(25)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            
            if authViewModel.user != nil {
                Button {
                    Task {
                        do {
                            try await commentService.blockUser(userId: userId)
                            alertTitle = "完了"
                            alertMessage = "ユーザーをブロックしました"
                            showAlert = true
                        } catch {
                            alertTitle = "エラー"
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill.xmark")
                        Text("ユーザーをブロックする")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, minHeight: 50)
                    .background(.orange)
                    .cornerRadius(25)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                
                Button {
                    Task {
                        do {
                            try await commentService.blockUser(userId: userId)
                            alertTitle = "完了"
                            alertMessage = "ユーザーをブロックしました"
                            showAlert = true
                        } catch {
                            alertTitle = "エラー"
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill.xmark")
                        Text("ユーザーをブロックする")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, minHeight: 50)
                    .background(.orange)
                    .cornerRadius(25)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}
