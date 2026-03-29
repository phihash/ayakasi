import SwiftUI

extension String: Identifiable {
    public var id: String { self }
}

struct SearchView: View {
    let screenWidth = UIScreen.main.bounds.width
    let itemSpacing: CGFloat = 30
    let categories = ["鳥山石燕","道の怪", "水の怪","音の怪","都市伝説","家の怪","動物の怪","山の怪","外国の妖怪","詳細不明"]
    @State private var selectedYokai : Ayakasi? = nil
    @State private var searchText = ""
    @State private var selectedCategoryForList: String? = nil
    
    func filteredYokais(for category: String) -> [Ayakasi] {
        let categoryFiltered = ayakasis.filter { $0.categories.contains(category) }
        
        if searchText.isEmpty {
            return categoryFiltered.shuffled()
        } else {
            return categoryFiltered.filter { ayakasi in
                ayakasi.name.contains(searchText) ||
                (ayakasi.searchKeywords?.contains(where: { $0.contains(searchText) }) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0){
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.appTextSecondary)
                        TextField("キーワード検索", text: $searchText)
                    }
                    .padding(10)
                    .background(Color.appTextFieldBackground)
                    .cornerRadius(10)
                    .padding(.bottom,12)
                    
                    Image("book2")
                        .renderingMode(.template)
                        .foregroundColor(.appTextSecondary)
                        .onTapGesture {
                            selectedCategoryForList = "すべて"
                        }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .background(Color.appBackground)
                
                ScrollView{
                    let allResults = categories.flatMap { filteredYokais(for: $0) }
                    
                    if !searchText.isEmpty && allResults.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.appTextSecondary)

                            Text("「\(searchText)」はヒットしませんでした")
                                .font(.headline)
                                .foregroundColor(.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(categories,id:\.self) { category in
                            let yokais = filteredYokais(for: category)
                            
                            if !yokais.isEmpty {
                                Button {
                                    selectedCategoryForList = category
                                } label: {
                                    HStack{
                                        Text(category)

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.appTextSecondary)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .font(.system(size: 18))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal,20)
                                    .padding(.vertical,12)
                                }
                                
                                ScrollView(.horizontal,showsIndicators: false){
                                    
                                    HStack(spacing: 12){
                                        ForEach(yokais, id: \.id) { ayakasi in
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
                                    .padding(.bottom,8)
                                }
                            }
                        }
                    }
                }
                .background(Color.appBackground)
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedCategoryForList) { category in
                AllYokaiListView(selectedCategory: category)
            }
        }
    }
}
