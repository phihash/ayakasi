import SwiftUI

struct CommentUI: View {
    @EnvironmentObject var commentStore: CommentService
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var commentText = ""
    @State private var isPosting = false
    @Binding var isPresented: Bool
    let yokai : Ayakasi

    private var commentLength: Int { CommentService.length(of: commentText) }
    private var isTooLong: Bool { commentLength > CommentService.maxLength }
    private var canPost: Bool {
        !isPosting && !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTooLong
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("コメントを投稿")
                .appFont(.headline)
                .fontWeight(.bold)
                .padding(.top, 20)

            // カスタムテキストフィールド
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("コメントを入力してください...", text: $commentText, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .lineLimit(3...6)
                            .appFont(.body)
                    }
                    .padding(16)
                    .background(Color.appTextSecondary.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextFieldFocused ? Color.appPrimary : Color.clear, lineWidth: 2)
                    )

                    Text("\(commentLength)/\(CommentService.maxLength)")
                        .appFont(.caption)
                        .foregroundStyle(isTooLong ? Color.red : Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                
                // 投稿ボタン
                Button(action: { // 投稿処理
                    guard canPost else { return }
                    isPosting = true
                    Task {
                        defer { isPosting = false }
                        do {
                            try await commentStore.postComment(content: commentText, yokai: yokai)
                            Analytics.trackCommentPosted(documentId: yokai.documentId)
                            await commentStore.fetchYokaiComments(yokaiId: yokai.documentId)
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
                        Text(isPosting ? "投稿中…" : "投稿する")
                    }
                    .appFont(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.appPrimary)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .disabled(!canPost)
                .opacity(canPost ? 1.0 : 0.5)

            Spacer()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .alert("エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

struct CommentEmptyState: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var thoughtBubble: some View {
        let outline = Path { line in
            line.move(to: CGPoint(x: 8, y: 24))
            line.addQuadCurve(to: CGPoint(x: 4, y: 12), control: CGPoint(x: -1, y: 22))
            line.addQuadCurve(to: CGPoint(x: 15, y: 7), control: CGPoint(x: 4, y: 5))
            line.addQuadCurve(to: CGPoint(x: 28, y: 4), control: CGPoint(x: 18, y: -1))
            line.addQuadCurve(to: CGPoint(x: 40, y: 8), control: CGPoint(x: 38, y: 1))
            line.addQuadCurve(to: CGPoint(x: 43, y: 21), control: CGPoint(x: 50, y: 14))
            line.addQuadCurve(to: CGPoint(x: 30, y: 27), control: CGPoint(x: 43, y: 29))
            line.addQuadCurve(to: CGPoint(x: 17, y: 28), control: CGPoint(x: 23, y: 33))
            line.addQuadCurve(to: CGPoint(x: 8, y: 24), control: CGPoint(x: 9, y: 31))
            line.closeSubpath()
        }
        return outline
            .fill(Color.appCardBackground)
            .overlay { outline.stroke(.brown.opacity(0.65), style: StrokeStyle(lineWidth: 1.4, lineJoin: .round)) }
            .frame(width: 48, height: 32)
    }

    private func swirl(progress: CGFloat) -> some View {
        Path { line in
            line.move(to: CGPoint(x: 2, y: 13))
            line.addCurve(to: CGPoint(x: 25, y: 5),
                          control1: CGPoint(x: 9, y: 14), control2: CGPoint(x: 18, y: -1))
            line.addCurve(to: CGPoint(x: 8, y: 14),
                          control1: CGPoint(x: 33, y: 13), control2: CGPoint(x: 12, y: 20))
            line.addCurve(to: CGPoint(x: 20, y: 5),
                          control1: CGPoint(x: 2, y: 8), control2: CGPoint(x: 15, y: 2))
            line.addCurve(to: CGPoint(x: 14, y: 13),
                          control1: CGPoint(x: 28, y: 9), control2: CGPoint(x: 18, y: 17))
            line.addQuadCurve(to: CGPoint(x: 30, y: 10), control: CGPoint(x: 12, y: 8))
        }
        .trim(from: 0, to: progress)
        .stroke(.brown, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 33, height: 18)
    }

    var body: some View {
        VStack(spacing: 12) {
            Image("comment-kozou")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.top, 8)
                .overlay(alignment: .topLeading) {
                    Circle().fill(.brown.opacity(0.55))
                        .frame(width: 3, height: 3).offset(x: 98, y: 39)
                    Circle().fill(.brown.opacity(0.55))
                        .frame(width: 5, height: 5).offset(x: 104, y: 32)

                    Group {
                        if reduceMotion {
                            thoughtBubble.overlay { swirl(progress: 1) }
                        } else {
                            thoughtBubble.keyframeAnimator(initialValue: CGFloat(0.22), repeating: true) { bubble, progress in
                                bubble.overlay { swirl(progress: progress) }
                            } keyframes: { _ in
                                CubicKeyframe(1, duration: 1.65)
                                LinearKeyframe(1, duration: 0.85)
                                CubicKeyframe(0.22, duration: 0.95)
                                LinearKeyframe(0.22, duration: 0.25)
                            }
                        }
                    }
                    .offset(x: 105)
                }
                .offset(x: 2)
                .accessibilityHidden(true)

            Text("まだコメントがありません")
                .appFont(.subheadline, weight: .medium)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
