import SwiftUI
import UIKit

extension Notification.Name {
    static let appIconDidChange = Notification.Name("appIconDidChange")
}

struct IconSelect: View {
    private enum AppIcon: String, CaseIterable, Identifiable {
        case primary
        case kappa = "KappaIcon"
        case rokuro = "RokuroIcon"

        var id: String { rawValue }

        var alternateIconName: String? {
            self == .primary ? nil : rawValue
        }

        var title: String {
            switch self {
            case .primary:
                return "小僧アイコン"
            case .kappa:
                return "河童アイコン"
            case .rokuro:
                return "ろくろ首アイコン"
            }
        }

        var imageName: String {
            switch self {
            case .primary:
                return "settingIcon"
            case .kappa:
                return "kappaicon1"
            case .rokuro:
                return "rokuroicon"
            }
        }
    }

    @State private var selectedIconName = UIApplication.shared.alternateIconName
    @State private var alertMessage: String?

    var body: some View {
        List {
            Section {
                ForEach(AppIcon.allCases) { icon in
                    Button {
                        changeIcon(to: icon)
                    } label: {
                        HStack(spacing: 14) {
                            Image(icon.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 54, height: 54)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                            Text(icon.title)
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            Spacer()

                            if selectedIconName == icon.alternateIconName {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appSecondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedIconName == icon.alternateIconName)
                }
            }
        }
        .navigationTitle("アプリアイコン")
        .navigationBarTitleDisplayMode(.inline)
        .alert("アイコンを変更できませんでした", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
        .onAppear {
            selectedIconName = UIApplication.shared.alternateIconName
        }
    }

    private func changeIcon(to icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else {
            alertMessage = "この端末ではアプリアイコンの変更に対応していません。"
            return
        }

        UIApplication.shared.setAlternateIconName(icon.alternateIconName) { error in
            DispatchQueue.main.async {
                if let error {
                    alertMessage = error.localizedDescription
                    return
                }

                selectedIconName = icon.alternateIconName
                NotificationCenter.default.post(name: .appIconDidChange, object: nil)
            }
        }
    }
}
