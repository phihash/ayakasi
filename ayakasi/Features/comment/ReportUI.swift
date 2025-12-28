import SwiftUI

struct ReportUI: View {
    @EnvironmentObject var commentService : CommentService
    let commentId: String
    var body: some View {
        VStack {
            Text("Report Comment")
            Text("ID: \(commentId)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .onTapGesture {
            print("🐛 ReportUI commentId: \(commentId)")
            Task {
                await commentService.reportRecentComment(documentId: commentId)
            }
        }
    }
}
