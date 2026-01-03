import SwiftUI

struct ReportUI: View {
    @EnvironmentObject var commentService : CommentService
    let commentId: String
    var body: some View {
        Button {
            Task {
                await commentService.reportRecentComment(documentId: commentId)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                Text("報告")
            }
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.9, minHeight: 50)
            .background(.red)
            .cornerRadius(25)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }
}
