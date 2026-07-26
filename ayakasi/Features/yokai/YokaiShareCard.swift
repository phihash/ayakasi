import SwiftUI
import UIKit

enum YokaiShareService {
    private static let appStoreURL = URL(string: "https://apps.apple.com/jp/app/%E5%A6%96%E6%80%AA%E5%9B%B3%E9%91%91/id6749905503")!

    @MainActor
    static func makePayload(for yokai: Ayakasi) async -> SharePayload {
        let image = await loadImage(for: yokai)
        let renderer = ImageRenderer(
            content: YokaiShareCard(yokai: yokai, yokaiImage: image)
                .frame(width: 1080, height: 1350)
        )
        renderer.scale = 1

        let message = "「\(yokai.name)」を妖怪図鑑でチェック！"
        if let cardImage = renderer.uiImage {
            return SharePayload(items: [cardImage, message, appStoreURL])
        }
        return SharePayload(items: [message, appStoreURL])
    }

    private static func loadImage(for yokai: Ayakasi) async -> UIImage? {
        if yokai.imageName == "NoImage" { return nil }

        if let url = URL(string: yokai.imageName), url.scheme?.hasPrefix("http") == true {
            guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
            return UIImage(data: data)
        }
        return UIImage(named: yokai.imageName)
    }
}

private struct YokaiShareCard: View {
    let yokai: Ayakasi
    let yokaiImage: UIImage?

    private var shortDescription: String {
        let normalized = yokai.description
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
        return normalized.count > 90
            ? String(normalized.prefix(90)) + "…"
            : normalized
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.10, blue: 0.13), Color(red: 0.20, green: 0.12, blue: 0.09)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                HStack {
                    Text("妖怪図鑑")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                    Spacer()
                    Text("この妖怪、知ってる？")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
                .padding(.horizontal, 64)
                .padding(.top, 58)
                .padding(.bottom, 38)

                Group {
                    if let yokaiImage {
                        Image(uiImage: yokaiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color.white.opacity(0.08)
                            Image(systemName: "sparkles")
                                .font(.system(size: 120))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .frame(width: 952, height: 650)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 38))

                VStack(alignment: .leading, spacing: 24) {
                    Text(yokai.name)
                        .font(.system(size: 72, weight: .bold, design: .serif))

                    Text(shortDescription)
                        .font(.system(size: 32))
                        .lineSpacing(9)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(3)

                    HStack {
                        Text("続きはアプリ「妖怪図鑑」で")
                            .font(.system(size: 27, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.72))
                        Spacer()
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 31))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 64)
                .padding(.top, 40)
                .padding(.bottom, 50)
            }
            .foregroundStyle(.white)
        }
    }
}

struct SharePayload: Identifiable {
    let id = UUID()
    let items: [Any]
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
