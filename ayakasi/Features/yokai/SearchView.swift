import SwiftUI

struct SearchView: View {
    let screenWidth = UIScreen.main.bounds.width
    let columns = Array(repeating: GridItem(.flexible(),spacing: 30), count: 3)
    let columns2 = [GridItem(.adaptive(minimum: 160, maximum: 260), spacing: 12)]
    @State private var selectedYokai : Ayakasi? = nil
    @State private var showYamanokai : Bool = false
    @State private var showMitinokai : Bool = false
    @State private var showMizunokai : Bool = false
    @State private var showGendainokai : Bool = false
    @State private var showOtonokai : Bool = false
    @State private var showIenokai : Bool = false
    @State private var showDoubutunokai : Bool = false
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView{
                    HStack{
                        Text("カテゴリ")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal,24)
                    .padding(.vertical,24)
                    
                    LazyVGrid(columns: columns){
                        VStack{
                            Text("🌊")
                                .font(.system(size: 100, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.gray,lineWidth: 3))
                                .onTapGesture{
                                    showMizunokai = true
                                }
                                .fullScreenCover(isPresented: $showMizunokai){
                                    YokaiCategoryView(ayakasis:ayakasis.filter({$0.categories.contains("水の怪")}), title:"水の怪")
                                }
                            Text("水の怪")
                                .fontWeight(.bold)
                        }
                        
                        VStack{
                            Text("⛰️")
                                .font(.system(size: 100, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.gray,lineWidth: 3))
                                .onTapGesture{
                                    showYamanokai = true
                                }
                                .fullScreenCover(isPresented: $showYamanokai){
                                    YokaiCategoryView(ayakasis:ayakasis.filter({$0.categories.contains("山の怪")}), title:"山の怪")
                                }
                            Text("山の怪")
                                .fontWeight(.bold)
                        }
                        
                        
                        
                        VStack{
                            Text("🛣️")
                                .font(.system(size: 100, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.gray,lineWidth: 3))
                                .onTapGesture{
                                    showMitinokai = true
                                }
                                .fullScreenCover(isPresented:  $showMitinokai){
                                    YokaiCategoryView(ayakasis:ayakasis.filter({$0.categories.contains("道の怪")}), title:"道の怪")
                                }
                            Text("道の怪")
                                .fontWeight(.bold)
                        }
                        
                        VStack{
                            Text("🧸")
                                .font(.system(size: 100, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.gray,lineWidth: 3))
                                .onTapGesture{
                                    showDoubutunokai = true
                                }
                                .fullScreenCover(isPresented:  $showDoubutunokai){
                                    YokaiCategoryView(ayakasis:ayakasis.filter({$0.categories.contains("動物の怪")}), title:"動物の怪")
                                }
                            Text("動物の怪")
                                .fontWeight(.bold)
                        }
                        
                        
                        
                        VStack{
                            Text("🏫")
                                .font(.system(size: 100, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.gray,lineWidth: 3))
                                .onTapGesture{
                                    showGendainokai = true
                                }
                                .fullScreenCover(isPresented: $showGendainokai){
                                    YokaiCategoryView(ayakasis:ayakasis.filter({$0.categories.contains("現代の怪")}), title:"現代の怪")
                                }
                            Text("現代の怪")
                                .fontWeight(.bold)
                        }
                        
                        VStack{
                            Text("🎶")
                                .font(.system(size: 100, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.gray,lineWidth: 3))
                                .onTapGesture{
                                    showOtonokai = true
                                }
                                .fullScreenCover(isPresented: $showOtonokai){
                                    YokaiCategoryView(ayakasis:ayakasis.filter({$0.categories.contains("音の怪")}),title: "音の怪")
                                }
                            Text("音の怪")
                                .fontWeight(.bold)
                        }
                        
                        VStack{
                            Text("🏠")
                                .font(.system(size: 100, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.gray,lineWidth: 3))
                                .onTapGesture{
                                    showIenokai = true
                                }
                                .fullScreenCover(isPresented: $showIenokai){
                                    YokaiCategoryView(ayakasis:ayakasis.filter({$0.categories.contains("家の怪")}),title: "家の怪")
                                }
                            Text("家の怪")
                                .fontWeight(.bold)
                        }
                        
                        
                        
                    }
                    .padding(.horizontal,28)
                    
                    // 3.インデックス
                    HStack{
                        Text("妖怪インデックス")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal,24)
                    .padding(.vertical,24)
                    
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
                    
                }
                .background(Color("Ivory"))
                
                
            }
            .safeAreaInset(edge: .top){
                CategoryBar()
            }
        }
    }
}

