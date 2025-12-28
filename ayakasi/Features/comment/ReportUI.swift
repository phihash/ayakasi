import SwiftUI

struct ReportUI: View {
    @EnvironmentObject var commentService : CommentService
    let commentId: String
    var body: some View {
        Button("Report Comment"){
            Task {
                await commentService.reportRecentComment(documentId: commentId)
            }
        }
    }
}
