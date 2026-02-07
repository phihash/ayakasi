import SwiftUI

struct BottomActionBar: View {
    let yokai: Ayakasi
    let screenWidth: CGFloat
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var colorVM: ColorViewModel
    @EnvironmentObject var voteVM: VoteService
    @Binding var isCommentUI: Bool

    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 16) {
                    Button{
                        isCommentUI.toggle()
                    } label: {
                        VStack(spacing:4){
                            Image(systemName: "bubble.left.and.bubble.right")
                            Text("コメント")
                        }
                    }
                        
                                        
                    // 戻るボタン
                    Button {
                        dismiss()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "arrowshape.turn.up.backward")
                            Text("戻る")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.black)
                    }
                }
                .padding(.trailing, 8)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(.white)
    }
}
