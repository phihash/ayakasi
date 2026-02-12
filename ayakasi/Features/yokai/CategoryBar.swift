import SwiftUI

// 1. カテゴリバー コード上では下だが画面上部に配置
struct CategoryBar : View{
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
                                .foregroundStyle(selectedCategory == category ? .white : .blue.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.vertical,6)
                                .padding(.horizontal,18)
                                .background(selectedCategory == category ? .blue.opacity(0.8) : Color.clear)
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.blue.opacity(0.8), lineWidth: 2)
                                )
                        }
                        
                    }
                }
                .padding(.bottom,18)
                .padding(.top,6)
                .padding(.leading,20)
                .padding(.trailing,24)
            }
        }
    }
}
