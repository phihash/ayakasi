import SwiftUI

struct CommentUI: View {
    @EnvironmentObject var commentStore: CommentService
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                TextField("コメントしてください", text: $commentStore.commentNow)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                
                HStack {
                    Text("投稿する")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: geometry.size.width * 0.55, height: 48)
                .background(Capsule().fill(.orange))
                .padding(.trailing, 10)
            }
            .padding(.top, 20)
        }
    }
}
