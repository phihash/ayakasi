import SwiftUI

struct SearchView: View {
    let screenWidth = UIScreen.main.bounds.width
    let itemSpacing: CGFloat = 30
    let categories = [
        "すべて", "道の怪", "水の怪","音の怪","都市伝説","家の怪","動物の怪","山の怪","外国の妖怪"
    ]
    @State private var selectedYokai : Ayakasi? = nil
    @EnvironmentObject var colorVM : ColorViewModel
    @State private var selectedCategory: String = "すべて"
    @State private var searchText = ""

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
            VStack{
                ScrollView{
                    CategoryBar(categories: categories,selectedCategory: $selectedCategory)
                    
                    LazyVGrid(columns: columns, spacing: itemSpacing){
                        ForEach(filteredYokai, id: \.id){ayakasi in
                            PickupCard(ayakasi: ayakasi)
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
            .navigationTitle("図鑑")
            .searchable(text: $searchText, prompt: "妖怪を検索")  
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

