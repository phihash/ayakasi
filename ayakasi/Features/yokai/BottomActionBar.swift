import SwiftUI

struct BottomActionBar: View {
    let yokai: Ayakasi
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var isCommentUI: Bool
    @State private var showLoginAlert = false
    @State private var sharePayload: SharePayload?
    @State private var isPreparingShare = false

    var body: some View {
        HStack(spacing: 16) {
            Spacer()

            Button {
                Task { await prepareShareCard() }
            } label: {
                ZStack {
                    actionIcon(
                        systemName: "square.and.arrow.up",
                        foregroundColor: Color.appTextPrimary
                    )
                    if isPreparingShare {
                        ProgressView()
                            .controlSize(.small)
                            .padding(5)
                            .background(.ultraThinMaterial, in: Circle())
                            .offset(x: 22, y: -22)
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
                actionIcon(
                    systemName: "bubble.left.and.bubble.right",
                    foregroundColor: Color.appTextPrimary
                )
            }
            .accessibilityLabel("コメント")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
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

    private func actionIcon(systemName: String, foregroundColor: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 25, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .frame(width: 62, height: 62)
            .background(
                Circle()
                    .fill(Color.appCardBackground.opacity(0.94))
            )
            .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 8)
    }
}
