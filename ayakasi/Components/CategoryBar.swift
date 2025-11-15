import SwiftUI

let categories = [
    "怖い", "夜道","人型","女性型","老人型","脅かす","都市伝説","動物","すべて"
]

// 1. カテゴリバー コード上では下だが画面上部に配置
struct CategoryBar : View{
    @EnvironmentObject var ColorVM : ColorViewModel
    @State private var selectedYokai : Ayakasi? = nil
    var body: some View{
        HStack{
            ScrollView(.horizontal,showsIndicators: false){
                HStack{
                    ForEach(categories.shuffled(), id: \.self){ category in
                        NavigationLink{
                            let filtered = ayakasis.filter({$0.tags.contains(category)})
                            FilteredScreen(ayakasis:filtered,tag:category)
                        } label :{
                            Text(category)
                                .font(.subheadline)
                                .foregroundStyle(ColorVM.currentColor.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.vertical,6)
                                .padding(.horizontal,18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(ColorVM.currentColor.opacity(0.8), lineWidth: 2)
                                )
                        }
                        
                    }
                }
                .padding(.vertical,18)
                .padding(.leading,12)
                .padding(.trailing,24)
            }
        }
    }
}
