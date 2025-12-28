import SwiftUI

struct ReportUI: View {
    @EnvironmentObject var commentService : CommentService
    let commentId: String
    var body: some View {
        Text("Report Comment")
            .onTapGesture {
                Task {
                    await commentService.reportRecentComment(documentId: commentId)
                }
            }
    }
}
