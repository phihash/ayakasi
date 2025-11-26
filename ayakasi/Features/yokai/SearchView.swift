import SwiftUI

struct SearchView: View {
    let screenWidth = UIScreen.main.bounds.width
    let itemSpacing: CGFloat = 20
    let categories = [
        "すべて", "道の怪", "水の怪","音の怪","都市伝説","家の怪","動物の怪","山の怪"
    ]
    @State private var selectedYokai : Ayakasi? = nil
    @EnvironmentObject var colorVM : ColorViewModel
    @State private var selectedCategory: String = "すべて"
    
    var body: some View {
        let availableWidth = screenWidth - 40 //padding引く
        let itemWidth = (availableWidth - itemSpacing) / 2
        let columns = Array(repeating: GridItem(.fixed(itemWidth),spacing: itemSpacing) , count: 2)
        
        NavigationStack{
            VStack{
                ScrollView{
                    CategoryBar(categories: categories,selectedCategory: $selectedCategory)
                        .padding(.leading,8)
                    
                    LazyVGrid(columns: columns){
                        ForEach(ayakasis.filter{ $0.categories.contains(selectedCategory) },id: \.id){ayakasi in
                            PickupCard(ayakasi: ayakasi)
                                .onTapGesture{
                                    selectedYokai = ayakasi
                                }
                                .fullScreenCover(item: $selectedYokai){ yokai in
                                    NeoDetail(yokai: yokai)
                                }
                            
                        }
                    }
                    .padding(.horizontal,20)
                    
                }
                .background(Color("Ivory"))
                .gesture(
                    DragGesture().onEnded { value in
                        let currentIndex = categories.firstIndex(of: selectedCategory) ?? 0
                        
                        if value.translation.width > 10 {
                            let newIndex = max(0, currentIndex - 1)
                            selectedCategory = categories[newIndex]
                        }else if value.translation.width < -10 {
                            let newIndex = min(categories.count - 1, currentIndex + 1)
                            selectedCategory = categories[newIndex]
                        }
                    }
                )
                
            }
            .navigationTitle("図鑑")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

