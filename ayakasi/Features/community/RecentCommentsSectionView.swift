import SwiftUI
import Kingfisher
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
            if authVM.user == nil {
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
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(comment["content"] as? String ?? "")
                                    .font(.subheadline)
                                    .lineLimit(3)

                                HStack{
                                    if let timestamp = comment["createdAt"] as? Timestamp {
                                        Text(DateFormatter.shortDateTime.string(from: timestamp.dateValue()))
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                            .fontWeight(.semibold)
                                    }

                                    Text(ayakasi.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.appTextSecondary)

                                    if ayakasi.story {
                                        Image("book2")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                    }

                                    Spacer()

                                    if let currentUserId = authVM.user?.uid,
                                       let commentUserId = comment["userId"] as? String,
                                       currentUserId != commentUserId {
                                        Image(systemName: "ellipsis")
                                            .font(.title3)
                                            .onTapGesture {
                                                guard let docId = comment["documentId"] as? String, !docId.isEmpty else {
                                                    return
                                                }

                                                selectedCommentId = docId
                                                reportTarget = ReportTarget(id: docId)

                                            }
                                    }

                                }
                                .padding(.top,4)
                            }

                            Spacer()

                            Group {
                                if let url = URL(string: ayakasi.imageName), url.scheme?.hasPrefix("http") == true {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    VStack {
                                        Text("👻")
                                            .font(.title2)
                                        Text("No picture")
                                            .font(.caption2)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                            }
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedYokai = ayakasi
                        }

                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}
