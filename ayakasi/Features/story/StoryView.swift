import SwiftUI

struct StoryView: View {
    let yokaiName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch yokaiName {
            case "清姫":
                Kiyohime()
            case "雪女":
                Yuki()
            case "のっぺらぼう":
                Oiteke()
            case "やまんば":
                Yamanba()
            case "座敷童":
                Zasikiwarasi()
            default:
                NavigationStack {
                    VStack {
                        Text("物語が見つかりません")
                            .font(.title)
                            .padding()
                    }
                    .navigationTitle(yokaiName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem {
                            Button("閉じる") {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}
