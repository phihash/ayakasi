import SwiftUI

struct BottomActionBar: View {
    let yokai: Ayakasi
    @EnvironmentObject var favoriteService: FavoriteService
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var isCommentUI: Bool
    @State private var showLoginAlert = false

    var body: some View {
        HStack(spacing: 16) {
            Spacer()

            Button {
                let willBeBookmarked = !favoriteService.isFavoriteYokai(yokai.documentId)
                favoriteService.toggleFavoriteYokai(yokai.documentId)
                Analytics.trackFavoriteToggled(yokaiName: yokai.name, documentId: yokai.documentId, isFavorite: willBeBookmarked)
            } label: {
                actionIcon(
                    systemName: favoriteService.isFavoriteYokai(yokai.documentId) ? "bookmark.fill" : "bookmark",
                    foregroundColor: Color.appHighlight
                )
            }
            .accessibilityLabel(favoriteService.isFavoriteYokai(yokai.documentId) ? "ブックマーク済み" : "ブックマーク")

            Button {
                if authVM.authStatus == .authenticated {
                    isCommentUI.toggle()
                } else {
                    showLoginAlert = true
                }
            } label: {
                actionIcon(
                    systemName: "bubble.left.and.bubble.right",
                    foregroundColor: Color.appTextPrimary
                )
            }
            .accessibilityLabel("コメント")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .alert("ログインが必要です", isPresented: $showLoginAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("コメントを投稿するには、設定画面からログインまたは新規登録してください。")
        }
    }

    private func actionIcon(systemName: String, foregroundColor: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 25, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .frame(width: 62, height: 62)
            .background(
                Circle()
                    .fill(Color.appCardBackground.opacity(0.94))
            )
            .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 8)
    }
}
