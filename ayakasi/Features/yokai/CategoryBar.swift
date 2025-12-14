import SwiftUI

// 1. カテゴリバー コード上では下だが画面上部に配置
struct CategoryBar : View{
    @EnvironmentObject var ColorVM : ColorViewModel
    let categories : [String]
    @Binding var selectedCategory : String
    var body: some View{
        HStack{
            ScrollView(.horizontal,showsIndicators: false){
                HStack{
                    ForEach(categories, id: \.self){ category in
                        Button {
                            selectedCategory = category
                        } label :{
                            Text(category)
                                .font(.subheadline)
                                .foregroundStyle(selectedCategory == category ? .white : ColorVM.currentColor.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.vertical,6)
                                .padding(.horizontal,18)
                                .background(selectedCategory == category ? ColorVM.currentColor.opacity(0.8) : Color.clear)
                                .cornerRadius(24)
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
