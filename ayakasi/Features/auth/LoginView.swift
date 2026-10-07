import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showResetConfirm = false
    @FocusState private var focus: Field?

    private enum Field { case email, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                VStack(spacing: 16) {
                    field(icon: "envelope", title: "メールアドレス", focused: focus == .email) {
                        TextField("mail@example.com", text: $authVM.email)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focus = .password }
                    }

                    field(icon: "lock", title: "パスワード", focused: focus == .password) {
                        SecureField("6文字以上", text: $authVM.password)
                            .textContentType(.password)
                            .focused($focus, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { submit() }
                    }
                }

                Button("パスワードをお忘れですか？") {
                    if authVM.email.isEmpty {
                        authVM.message = "再設定にはメールアドレスの入力が必要です"
                        focus = .email
                    } else {
                        showResetConfirm = true
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.appSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(authVM.isProcessing)

                if !authVM.message.isEmpty {
                    Label(authVM.message, systemImage: "exclamationmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.appError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                loginButton
                    .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.appBackground.ignoresSafeArea())
        .animation(.easeOut(duration: 0.2), value: authVM.message)
        .onDisappear {
            authVM.email = ""
            authVM.password = ""
            authVM.message = ""
        }
        .alert("パスワード再設定", isPresented: $showResetConfirm) {
            Button("送信") { Task { await authVM.forgotPassword() } }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("\(authVM.email) に再設定メールを送信します")
        }
        .navigationTitle("ログイン")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 16) {
            Image("settingIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 14, y: 6)

            VStack(spacing: 6) {
                Text("おかえりなさい")
                    .font(.title.bold())
                    .foregroundStyle(Color.appTextPrimary)
                Text("メールアドレスでログイン")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
    }

    private var loginButton: some View {
        Button(action: submit) {
            Group {
                if authVM.isProcessing {
                    ProgressView().tint(.white)
                } else {
                    Text("ログイン").font(.headline)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Color.appSecondary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: Color.appSecondary.opacity(0.35), radius: 16, y: 8)
        }
        .buttonStyle(PressableScale())
        .disabled(authVM.isProcessing)
        .opacity(authVM.isProcessing ? 0.9 : 1)
    }

    private func submit() {
        Task {
            await authVM.signIn()
            if authVM.authStatus == .authenticated {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func field<Content: View>(
        icon: String,
        title: String,
        focused: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(focused ? Color.appSecondary : Color.appTextSecondary)
                    .frame(width: 22)
                content()
                    .font(.system(size: 17))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color.appTextFieldBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(focused ? Color.appSecondary : Color.appTextPrimary.opacity(0.06),
                            lineWidth: focused ? 1.5 : 1)
            )
            .animation(.easeOut(duration: 0.15), value: focused)
        }
    }
}

private struct PressableScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
