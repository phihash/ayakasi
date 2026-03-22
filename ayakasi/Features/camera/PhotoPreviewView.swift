import SwiftUI
import UIKit

enum PhotoSource {
    case camera
    case library
}

struct PhotoPreviewView: View {
    let capturedImage: UIImage
    let onSave: () -> Void
    let onRetake: () -> Void
    let source: PhotoSource

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 撮影した写真を表示
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()

                // アクションボタン
                VStack {
                    Spacer()
                    actionButtons
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button {
                onRetake()
            } label: {
                Label(
                    source == .camera ? "やり直し" : "キャンセル",
                    systemImage: source == .camera ? "arrow.counterclockwise" : "xmark"
                )
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            Button {
                onSave()
            } label: {
                Label("投稿に使う", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}
