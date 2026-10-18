import SwiftUI

struct BottomActionBar: View {
    let yokai: Ayakasi
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var isCommentUI: Bool
    @State private var showLoginAlert = false
    @State private var sharePayload: SharePayload?
    @State private var isPreparingShare = false

    var body: some View {
        VStack(spacing: 10) {
            Button {
                Task { await prepareShareCard() }
            } label: {
                ZStack {
                    ActionCircleIcon(systemName: "square.and.arrow.up")
                    if isPreparingShare {
                        ProgressView()
                            .controlSize(.small)
                            .padding(5)
                            .background(.ultraThinMaterial, in: Circle())
                            .offset(x: 16, y: -16)
                    }
                }
            }
            .disabled(isPreparingShare)
            .accessibilityLabel("シェア")

            Button {
                if authVM.authStatus == .authenticated {
                    isCommentUI.toggle()
                } else {
                    showLoginAlert = true
                }
            } label: {
                ActionCircleIcon(systemName: "bubble.left.and.bubble.right")
            }
            .accessibilityLabel("コメント")
        }
        .padding(.trailing, 22)
        .padding(.bottom, 14)
        .alert("ログインが必要です", isPresented: $showLoginAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("コメントを投稿するには、設定画面からログインまたは新規登録してください。")
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(activityItems: payload.items)
                .presentationDetents([.medium, .large])
        }
    }

    @MainActor
    private func prepareShareCard() async {
        isPreparingShare = true
        defer { isPreparingShare = false }

        sharePayload = await YokaiShareService.makePayload(for: yokai)
        Analytics.trackAppShared()
    }
}

/// 画面の右下に浮かせる丸いボタンの見た目(妖怪詳細とコメントのタブで共通)
struct ActionCircleIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: 46, height: 46)
            .background(
                Circle()
                    .fill(Color.appCardBackground.opacity(0.94))
            )
            .shadow(color: .black.opacity(0.14), radius: 10, x: 0, y: 4)
    }
}
