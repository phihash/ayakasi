import SwiftUI

struct BottomActionBar: View {
    let yokai: Ayakasi
    let screenWidth: CGFloat
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var voteVM: VoteService
    @EnvironmentObject var favoriteService: FavoriteService
    @Binding var isCommentUI: Bool
    @Binding var voteSuccess: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                // 投票ボタン
                Button {
                    Task {
                        do {
                            try await voteVM.vote(aykasiId: yokai.documentId)
                            voteSuccess.toggle()
                        } catch let error as VoteError {
                            alertMessage = error.localizedDescription
                            showAlert = true
                        } catch {
                            alertMessage = "投票中にエラーが発生しました"
                            showAlert = true
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.appError)
                        Text("\(voteVM.voteCountCache[yokai.documentId] ?? 0)")
                            .font(.caption)
                            .foregroundStyle(Color.appTextBlack)
                    }
                }
                .sensoryFeedback(.success, trigger: voteSuccess)
                .frame(maxWidth: .infinity)

                // お気に入りボタン
                Button {
                    favoriteService.toggleFavoriteYokai(yokai.documentId)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: favoriteService.isFavoriteYokai(yokai.documentId) ? "star.fill" : "star")
                            .foregroundStyle(Color.appHighlight)
                        Text("お気に入り")
                            .font(.caption)
                            .foregroundStyle(Color.appTextBlack)
                    }
                }
                .frame(maxWidth: .infinity)

                // 既読ボタン
                Button {
                    favoriteService.toggleReadYokai(yokai.documentId)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: favoriteService.isReadYokai(yokai.documentId) ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundStyle(Color.appSuccess)
                        Text("既読")
                            .font(.caption)
                            .foregroundStyle(Color.appTextBlack)
                    }
                }
                .frame(maxWidth: .infinity)

                // コメントボタン
                Button {
                    isCommentUI.toggle()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundStyle(Color.appTextBlack)
                        Text("コメント")
                            .font(.caption)
                            .foregroundStyle(Color.appTextBlack)
                    }
                }
                .frame(maxWidth: .infinity)

                // 戻るボタン
                Button {
                    dismiss()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "arrowshape.turn.up.backward")
                        Text("戻る")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.appTextBlack)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(Color.appCardBackground)
    }
}
