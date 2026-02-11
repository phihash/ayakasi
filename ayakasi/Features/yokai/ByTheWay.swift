import SwiftUI

struct ByTheWay: View {
    let btw : String
    @EnvironmentObject var colorVM : ColorViewModel
    var body: some View {
        VStack{
            HStack{
                Text("ちなみに")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom,12)
            
            Text(btw)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .foregroundStyle(.black)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal,16)
        .padding(.bottom,8)
    }
}
