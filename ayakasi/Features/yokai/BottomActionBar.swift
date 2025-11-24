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
                    // 投票ボタン（ハート）
                    Button {
                        Task {
                            do {
                                try await voteVM.vote(aykasiId: yokai.documentId)
                                print("投票完了！")
                            } catch {
                                print("投票エラー: \(error)")
                            }
                        }
                    } label: {
                        VStack{
                            Circle()
                                .fill(Color.red.opacity(0.6))
                                .frame(width: screenWidth * 0.12, height: screenWidth * 0.12)
                                .overlay(
                                    VStack(spacing: 2){
                                        Image(systemName: "heart")
                                            .foregroundStyle(.white)
                                        Text("\(voteVM.voteCounts[yokai.documentId] ?? 0)")
                                            .foregroundStyle(.white)
                                    }
                                    
                                )
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
        .onAppear {
            Task {
                _ = await voteVM.getVoteCount(ayakasiId: yokai.documentId)
            }
        }
    }
}
