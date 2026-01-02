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
                    .font(.subheadline)
                Text("報告")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.1))
            .cornerRadius(16)
        }
    }
}
