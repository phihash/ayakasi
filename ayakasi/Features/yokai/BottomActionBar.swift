import SwiftUI

struct BottomActionBar: View {
    let yokai: Ayakasi
    let screenWidth: CGFloat
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var colorVM: ColorViewModel
    @EnvironmentObject var voteVM: VoteService
    
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
                .frame(width: screenWidth * 0.6, height: 48)
                .background(Capsule().fill(colorVM.currentColor))
                .padding(.trailing, 12)
                .onTapGesture {
                    requestAndSaveImage(yokai.imageName)
                }
                
                HStack(spacing: 18) {
                    Link(destination: URL(string: "https://www.google.com/search?q=\(yokai.name)")!){
                        VStack(spacing:4){
                            Image(systemName: "magnifyingglass")
                            Text("検索")
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
