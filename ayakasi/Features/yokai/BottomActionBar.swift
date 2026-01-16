import SwiftUI

struct BottomActionBar: View {
    let yokai: Ayakasi
    let screenWidth: CGFloat
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var colorVM: ColorViewModel
    @EnvironmentObject var voteVM: VoteService
    @Binding var isCommentUI: Bool
    let requestAndSaveImage: (String) -> Void
    
    var body: some View {
        VStack {
            HStack {
                // 写真を保存ボタン
                HStack {
                    Text("写真を保存")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: screenWidth * 0.55, height: 48)
                .background(Capsule().fill(colorVM.currentColor))
                .padding(.trailing, 10)
                .onTapGesture {
                    requestAndSaveImage(yokai.imageName)
                }
                
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
