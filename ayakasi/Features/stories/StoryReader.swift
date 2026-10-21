import SwiftUI

/// 物語の読み物画面。5つの物語で同じ見た目にするため、各物語は章のデータだけを持つ
struct StoryReader: View {
    let title: String
    let color: Color
    let sections: [(title: String, body: String)]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    Rectangle()
                        .fill(color)
                        .frame(width: 40, height: 3)
                        .padding(.bottom, 32)

                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        Text("第\(index + 1)章")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(color)
                        Text(section.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top, 4)
                        // 太字にしないのは、長い本文が太字だと読み疲れるため
                        Text(section.body)
                            .lineSpacing(9)
                            .padding(.top, 12)
                            .padding(.bottom, 40)
                    }
                }
                .frame(maxWidth: 600, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            // 明朝体にするのは、図鑑の解説と分けて「読み物」として見せるため
            .fontDesign(.serif)
            .background(Color.appBackground)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}
