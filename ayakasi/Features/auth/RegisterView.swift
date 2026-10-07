import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var focus: Field?

    private enum Field { case email, password, confirm }

    var body: some View {
        ScrollView {
            Group {
                if authVM.authStatus == .waitingVerification {
                    verificationSent
                } else {
                    form
                }
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
        .navigationTitle("新規登録")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var form: some View {
        VStack(spacing: 24) {
            AuthHeader(title: "妖怪図鑑", subtitle: "メールアドレスで登録")

            VStack(spacing: 16) {
                AuthField(icon: "envelope", title: "メールアドレス", focused: focus == .email) {
                    TextField("mail@example.com", text: $authVM.email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focus = .password }
                }

                AuthField(icon: "lock", title: "パスワード", focused: focus == .password) {
                    SecureField("6文字以上", text: $authVM.password)
                        .textContentType(.newPassword)
                        .focused($focus, equals: .password)
                        .submitLabel(.next)
                        .onSubmit { focus = .confirm }
                }

                AuthField(icon: "lock.rotation", title: "パスワード（確認）", focused: focus == .confirm) {
                    SecureField("もう一度入力", text: $authVM.confirmPassword)
                        .textContentType(.newPassword)
                        .focused($focus, equals: .confirm)
                        .submitLabel(.go)
                        .onSubmit { Task { await authVM.signUp() } }
                }
            }

            AuthMessage(text: authVM.message)

            AuthPrimaryButton(title: "登録", isLoading: authVM.isProcessing) {
                Task { await authVM.signUp() }
            }
            .padding(.top, 4)

            terms
        }
    }

    private var terms: some View {
        VStack(spacing: 10) {
            Text("登録すると利用規約およびプライバシーポリシーに同意したものとみなされます。")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                NavigationLink(destination: WebView(url: URL(string: AppConstants.termsOfServiceURL))) {
                    Text("利用規約")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appSecondary)
                }
                NavigationLink(destination: WebView(url: URL(string: AppConstants.privacyPolicyURL))) {
                    Text("プライバシーポリシー")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appSecondary)
                }
            }
        }
        .padding(.top, 4)
    }

    private var verificationSent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "envelope.badge.shield.half.filled")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.appSecondary)
                    .padding(.bottom, 4)

                Text("認証メールを送信しました")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text("届いたメールのリンクを開いて認証を完了してください。見当たらないときは迷惑メールフォルダもご確認ください。")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 48)

            AuthPrimaryButton(title: "メールを確認した", isLoading: authVM.isProcessing) {
                Task {
                    await authVM.checkEmailVerification()
                    if authVM.authStatus == .authenticated { dismiss() }
                }
            }
            .padding(.top, 8)

            Button("認証メールを再送信") {
                Task { await authVM.resendVerificationEmail() }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.appSecondary)
            .disabled(authVM.isProcessing)
        }
    }
}
