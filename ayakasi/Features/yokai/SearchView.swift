import SwiftUI

struct SearchView: View {
    let screenWidth = UIScreen.main.bounds.width
    let itemSpacing: CGFloat = 30
    let categories = [
        "すべて", "道の怪", "水の怪","音の怪","都市伝説","家の怪","動物の怪","山の怪","外国の妖怪","詳細不明"
    ]
    @State private var selectedYokai : Ayakasi? = nil
    @EnvironmentObject var colorVM : ColorViewModel
    @State private var selectedCategory: String = "すべて"
    @State private var searchText = ""
    @State private var showAllYokaiList = false

    var filteredYokai: [Ayakasi] {
        let categoryFiltered = ayakasis.filter { $0.categories.contains(selectedCategory) }

        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { ayakasi in
                ayakasi.name.contains(searchText) ||
                (ayakasi.searchKeywords?.contains(where: { $0.contains(searchText) }) ?? false)
            }
        }
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: itemSpacing), count: 3)
        
        NavigationStack{
            VStack(spacing: 0){
                
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("キーワード検索", text: $searchText)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Image("book2")
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showAllYokaiList = true
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("Ivory"))

                ScrollView{
                    CategoryBar(categories: categories,selectedCategory: $selectedCategory)

                    
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
                .background(Color("Ivory"))
                .gesture(
                    DragGesture().onEnded { value in
                        let currentIndex = categories.firstIndex(of: selectedCategory) ?? 0
                        if value.translation.width > 4 {
                            let newIndex = max(0, currentIndex - 1)
                            selectedCategory = categories[newIndex]
                        }else if value.translation.width < -4 {
                            let newIndex = min(categories.count - 1, currentIndex + 1)
                            selectedCategory = categories[newIndex]
                        }
                    }
                )
                
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showAllYokaiList) {
                AllYokaiListView()
            }
        }
    }
}
