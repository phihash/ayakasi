import SwiftUI

struct SearchView: View {
    let screenWidth = UIScreen.main.bounds.width
    let columns = Array(repeating: GridItem(.flexible(),spacing: 30), count: 3)
    @State private var selectedYokai : Ayakasi? = nil
    @State private var showYamanokai : Bool = false
    @State private var showMitinokai : Bool = false
    @State private var showMizunokai : Bool = false
    @State private var showGendainokai : Bool = false
    @State private var showOtonokai : Bool = false
    @State private var showIenokai : Bool = false
    @State private var showDoubutunokai : Bool = false
    @EnvironmentObject var colorVM : ColorViewModel
   
    var body: some View {
        let yokaiScreenWidth = UIScreen.main.bounds.width
        let itemSpacing: CGFloat = 10
        let availableWidth = yokaiScreenWidth - (20)
        let itemWidth = (availableWidth - (itemSpacing * 2)) / 2
        let columns2 = Array(repeating: GridItem(.fixed(itemWidth),spacing: itemSpacing) , count: 2)
        
        NavigationStack{
            VStack{
                ScrollView{
                    CategoryBar()
                    
                    LazyVGrid(columns: columns2){
                        ForEach(ayakasis,id: \.id){ayakasi in
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
                
            }
            .toolbar{
                ToolbarItem(placement:.navigationBarTrailing){
                    NavigationLink(destination: SettingView() ){
                        Image("setting")
                    }
                }
            }
            .navigationTitle("図鑑")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

