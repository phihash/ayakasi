import SwiftUI

struct CommentUI: View {
    @EnvironmentObject var commentStore: CommentService
    var body: some View {
        TextField("コメントしてください", text: $commentStore.commentNow)
        Button("投稿") {
            // 投稿処理
        }

    }
}
