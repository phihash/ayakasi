import SwiftUI

struct AllYokaiListView: View {
    let screenWidth = UIScreen.main.bounds.width
    let itemSpacing: CGFloat = 30
    let categories = YokaiCategories.allCategories
    @State private var selectedYokai : Ayakasi? = nil
    @State private var isAlphabetical = false
    let selectedCategory: String
    @Environment(\.dismiss) var dismiss

    var filteredYokai: [Ayakasi] {
        var result: [Ayakasi]
        if selectedCategory == "すべて" {
            result = ayakasis
        } else {
            result = ayakasis.filter { $0.categories.contains(selectedCategory) }
        }
        if isAlphabetical {
            result.sort { $0.name.compare($1.name, locale: Locale(identifier: "ja_JP")) == .orderedAscending }
        }
        return result
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
                .padding(.top, 24)
                .background(Color("Ivory"))
                .overlay(alignment: .bottomTrailing){
                    Button{
                        isAlphabetical.toggle()
                    } label: {
                        Text(isAlphabetical ? "デフォルト順にする" : "五十音順にする")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 12)
                    .padding(.trailing, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
