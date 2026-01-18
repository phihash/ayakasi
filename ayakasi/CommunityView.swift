import SwiftUI
import Kingfisher
import FirebaseFirestore

struct ReportTarget: Identifiable { let id: String }

struct CommunityView: View {
    @EnvironmentObject var commentService  : CommentService
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedYokai : Ayakasi? = nil
    @State private var selectedCommentId : String = ""
    @State private var reportTarget: ReportTarget? = nil
    var body: some View {
        NavigationStack{
            ScrollView{
                HStack{
                    Text("最近のコメント")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal,24)
                .padding(.vertical,12)

                // 未ログインユーザー向けの注意書き
                if authVM.user == nil {
                    HStack(spacing: 8) {
                        Text("コメントの投稿・通報・ブロックはログインが必要です")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.4))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }

                if commentService.isLoadingRecentComments {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)

                        Text("最新のコメントを取得中です")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    .frame(height: 120)
                } else if commentService.recentComments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)

                        Text("コメントはありません")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    .frame(height: 120)
                } else {
                    ForEach(commentService.recentComments.indices, id: \.self) { index in
                        let comment = commentService.recentComments[index]
                        let yokaiId = comment["yokaiId"] as? String ?? ""
                        
                        if let ayakasi = ayakasis.first(where: { $0.documentId == yokaiId }) {
                            HStack(spacing: 12) {
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
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack{
                                        Spacer()
                                        if authVM.user != nil {
                                            Image(systemName: "ellipsis")
                                                .font(.title3)
                                                .onTapGesture {
                                                    guard let docId = comment["documentId"] as? String, !docId.isEmpty else {
                                                        print("❗️ documentId is missing; not opening report sheet")
                                                        return
                                                    }

                                                    selectedCommentId = docId
                                                    reportTarget = ReportTarget(id: docId)

                                                }
                                        }
                                    }
                                    .padding(.bottom,12)
                                    Text(comment["content"] as? String ?? "")
                                        .font(.subheadline)
                                        .lineLimit(3)
                                    
                                    HStack{
                                        if let timestamp = comment["createdAt"] as? Timestamp {
                                            Text(DateFormatter.shortDateTime.string(from: timestamp.dateValue()))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .fontWeight(.semibold)
                                            
                                        }
                                        
                                        Text(ayakasi.name)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray)
                                        
                                    }
                                    .padding(.top,4)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedYokai = ayakasi
                            }
                        }
                    }
                }
                
            }
            .onAppear{
                Task{
                    await commentService.getRecentComments()
                }
            }
            .fullScreenCover(item: $selectedYokai){ yokai in
                NeoDetail(yokai: yokai)
            }
            .sheet(item: $reportTarget) { target in
                if let comment = commentService.recentComments.first(where: { ($0["documentId"] as? String) == target.id }),
                   let userId = comment["userId"] as? String {
                    ReportUI(commentId: target.id, userId: userId)
                        .presentationDetents([.fraction(0.25)])
                        .presentationBackground(.regularMaterial)
                }
            }
        }
    }
}
