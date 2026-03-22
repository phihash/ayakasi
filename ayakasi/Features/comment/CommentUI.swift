import SwiftUI
import PhotosUI
import UIKit

struct CommentUI: View {
    @EnvironmentObject var commentStore: CommentService
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var commentText = ""
    @State private var showCamera = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @Binding var isPresented: Bool
    let yokai : Ayakasi
    var body: some View {
        VStack(spacing: 20) {
            if authVM.user != nil {
                Text("コメントを投稿")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // カスタムテキストフィールド
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("コメントを入力してください...", text: $commentText, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .lineLimit(3...6)
                            .font(.body)
                    }
                    .padding(16)
                    .background(Color.appTextSecondary.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextFieldFocused ? Color.appPrimary : Color.clear, lineWidth: 2)
                    )
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    // カメラボタン
                    Button {
                        showCamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("写真を撮る")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.appSecondary)
                        .cornerRadius(30)
                    }

                    // ライブラリボタン
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                            Text("ライブラリ")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.appSecondary)
                        .cornerRadius(30)
                    }

                }
                .padding(.horizontal, 20)

                //プレビュー
                if let capturedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)

                        // 削除ボタン
                        Button {
                            self.capturedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(8)
                    }
                    .padding(.horizontal, 20)
                }

                // 投稿ボタン
                Button(action: { // 投稿処理
                    Task {
                        do {
                            try await commentStore.postComment(content: commentText, yokai: yokai)
                            print("🔄 fetchYokaiComments呼び出し")
                            await commentStore.fetchYokaiComments(yokaiId: yokai.documentId)
                            print("🏁 投稿処理完了")
                            commentText = ""
                            isPresented = false
                        } catch {
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                    isTextFieldFocused = false
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("投稿する")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.appPrimary)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                
                Spacer()
            } else {
                Spacer()

                Text("ログインが必要です")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text("コメントを投稿するにはログインまたは新規登録してください")
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Button {
                        isPresented = false
                        authVM.showLogin()
                    } label: {
                        Text("ログイン")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.appPrimary)
                            .cornerRadius(25)
                    }

                    Button {
                        isPresented = false
                        authVM.showRegister()
                    } label: {
                        Text("新規登録")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.appSuccess)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

            }
        }
        .onTapGesture {
            if authVM.user != nil {
                isTextFieldFocused = false
            }
        }
        .alert("エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showCamera) {
            YokaiCameraView(
                onPhotoCapture: { image in
                    capturedImage = image
                    showCamera = false
                }
            )
        }
        .onChange(of: selectedPhoto) { (oldValue: PhotosPickerItem?, newValue: PhotosPickerItem?) in
            Task {
                if let newValue,
                   let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        capturedImage = image
                    }
                }
            }
        }
    }
}
