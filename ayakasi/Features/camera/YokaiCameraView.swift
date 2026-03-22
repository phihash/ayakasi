import SwiftUI
import UIKit

struct YokaiCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var showPreview = false

    var onPhotoCapture: ((UIImage) -> Void)?

    var body: some View {
        ZStack {
            if showPreview, let image = capturedImage {
                PhotoPreviewView(
                    capturedImage: image,
                    onSave: {
                        if let onPhotoCapture {
                            onPhotoCapture(image)
                        } else {
                            dismiss()
                        }
                    },
                    onRetake: {
                        showPreview = false
                        capturedImage = nil
                        cameraManager.capturedPhoto = nil
                    },
                    source: .camera
                )
            } else {
                cameraView
            }
        }
        .onChange(of: cameraManager.capturedPhoto) { (oldValue: UIImage?, newValue: UIImage?) in
            if let photo = newValue {
                capturedImage = photo
                showPreview = true
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }

    private var cameraView: some View {
        ZStack {
            if cameraManager.isAuthorized {
                // カメラプレビュー（妖怪なし）
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()

                VStack {
                    // 閉じるボタン
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()

                        Spacer()
                    }

                    Spacer()

                    // 撮影ボタン
                    Button {
                        cameraManager.capturePhoto()
                    } label: {
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .padding(.bottom, 40)
                }
            } else {
                permissionDeniedView
            }
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("カメラへのアクセスが必要です")
                .font(.headline)

            Text("設定からカメラへのアクセスを許可してください")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button("閉じる") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}
