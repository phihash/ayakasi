import SwiftUI

struct StorySectionNumber: View {
    let colorName : Color
    let numberString : String
    let title : String
    var body: some View {
        HStack{
            Circle().fill(colorName.opacity(0.2)).frame(width: 28, height: 28)
                .overlay{Text(numberString)
                        .fontWeight(.bold)
                    .foregroundStyle(colorName)}
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal,4)
            
            Spacer()
        }
        .padding(.horizontal,20)
        .padding(.top,12)
    }
}
