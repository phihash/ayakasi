import SwiftUI
import Kingfisher
import FirebaseFirestore

struct CommunityView: View {
    @EnvironmentObject var commentService  : CommentService
    @State private var selectedYokai : Ayakasi? = nil
    @State private var isReportUI : Bool = false
    @State private var selectedCommentId : String = ""
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
                
                if commentService.recentComments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("最新のコメントを取得中です")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    .frame(height: 120)
                } else{
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
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack{
                                        Spacer()
                                        Image(systemName: "ellipsis")
                                            .font(.title3)
                                            .onTapGesture {
                                                selectedCommentId = comment["documentId"] as? String ?? ""
                                                isReportUI = true
                                            }
                                    }
                                    Text(comment["content"] as? String ?? "")
                                        .font(.title3)
                                        .lineLimit(2)
                                    
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
            .sheet(isPresented: $isReportUI) {
                ReportUI(commentId: selectedCommentId)
                    .presentationDetents([.fraction(0.35)])
                    .presentationBackground(.regularMaterial)
            }
            
        }
    }
}

