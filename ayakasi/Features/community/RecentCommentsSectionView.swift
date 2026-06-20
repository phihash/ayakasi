import SwiftUI
import FirebaseFirestore

struct RecentCommentsSectionView: View {
    @EnvironmentObject var commentService: CommentService
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var selectedYokai: Ayakasi?
    @Binding var selectedCommentId: String
    @Binding var reportTarget: ReportTarget?

    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("最近のコメント")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal,20)
            .padding(.top,12)
            .padding(.bottom,4)

            // 未ログインユーザー向けの注意書き
            if authVM.authStatus != .authenticated {
                HStack(spacing: 8) {
                    Text("コメントの投稿・通報・ブロックはログインが必要です")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)
                        .opacity(0.4)
                    Spacer()
                }
                .padding(.horizontal,24)
            }

            if commentService.isLoadingRecentComments {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)

                    Text("最新のコメントを取得中です")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(height: 120)
            } else if commentService.recentComments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextSecondary)

                    Text("コメントはありません")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(height: 120)
            } else {
                ForEach(Array(commentService.recentComments.enumerated()), id: \.offset) { index, comment in
                    let yokaiId = comment["yokaiId"] as? String ?? ""

                    if let ayakasi = ayakasis.first(where: { $0.documentId == yokaiId }) {
                        CommentCardItem(
                            content: comment["content"] as? String ?? "",
                            yokaiName: ayakasi.name,
                            imageURL: ayakasi.imageName,
                            dateText: (comment["createdAt"] as? Timestamp).map {
                                DateFormatter.shortDateTime.string(from: $0.dateValue())
                            },
                            currentUserId: authVM.authStatus == .authenticated ? authVM.user?.uid : nil,
                            commentUserId: comment["userId"] as? String,
                            onTap: {
                                selectedYokai = ayakasi
                            },
                            onReport: {
                                guard let docId = comment["documentId"] as? String, !docId.isEmpty else {
                                    return
                                }
                                selectedCommentId = docId
                                reportTarget = ReportTarget(id: docId)
                            }
                        )
                    }
                }
            }
        }
    }
}
