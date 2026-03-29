import SwiftUI

struct AllYokaiListView: View {
    let screenWidth = UIScreen.main.bounds.width
    let itemSpacing: CGFloat = 30
    let categories = [
        "すべて","鳥山石燕", "道の怪", "水の怪","音の怪","都市伝説","家の怪","動物の怪","山の怪","外国の妖怪","詳細不明"
    ]
    @State private var selectedYokai : Ayakasi? = nil
    let selectedCategory: String
    @Environment(\.dismiss) var dismiss

    var filteredYokai: [Ayakasi] {
        if selectedCategory == "すべて" {
            return ayakasis
        } else {
            return ayakasis.filter { $0.categories.contains(selectedCategory) }
        }
    }

    // デバイスに応じて列数を変更
    var columnCount: Int {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 6  // iPadは6列
        } else {
            return 3  // iPhoneは3列
        }
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: itemSpacing), count: columnCount)

        NavigationStack{
            VStack(spacing: 0){
                // ヘッダー
                HStack {
                    Text("閉じる")
                        .opacity(0)
                    
                    Spacer()
                    Text(selectedCategory == "すべて" ? "全ての妖怪" : selectedCategory)
                        .font(.headline)
                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Text("閉じる")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .background(Color("Ivory"))

                ScrollView{
                    LazyVGrid(columns: columns, spacing: itemSpacing){
                        ForEach(filteredYokai, id: \.id){ayakasi in
                            NeoCardItem(item: ayakasi)
                                .onTapGesture{
                                    selectedYokai = ayakasi
                                }
                                .fullScreenCover(item: $selectedYokai){ yokai in
                                    NavigationStack {
                                        NeoDetail(yokai: yokai)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal,20)
                }
                .padding(.top,24)
                .background(Color("Ivory"))
            }
            .navigationBarHidden(true)
        }
    }
}
