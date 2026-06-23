import SwiftUI

struct ReportUI: View {
    @EnvironmentObject var reportService: CommentReportService
    @EnvironmentObject var blockingService: UserBlockingService
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var favoriteService: FavoriteService
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    let commentId: String
    let userId: String

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.appTextSecondary.opacity(0.18))
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 12)

            actionRow(
                title: "コメントを報告する",
                systemImage: "exclamationmark.triangle",
                foregroundColor: Color.appError
            ) {
                reportComment()
            }

            if authViewModel.authStatus == .authenticated {
                actionRow(
                    title: "ユーザーをブロックする",
                    systemImage: "person.fill.xmark",
                    foregroundColor: Color.appTextPrimary
                ) {
                    blockUser()
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func actionRow(
        title: String,
        systemImage: String,
        foregroundColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 18) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 28)

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func reportComment() {
        Task {
            do {
                try await reportService.reportComment(documentId: commentId)
                alertTitle = "完了"
                alertMessage = "報告が完了しました"
                showAlert = true
            } catch {
                alertTitle = "エラー"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func blockUser() {
        Task {
            do {
                try await blockingService.blockUser(userId: userId)
                alertTitle = "完了"
                alertMessage = "ユーザーをブロックしました"
                showAlert = true
            } catch {
                alertTitle = "エラー"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}
