import SwiftUI

struct ByTheWay: View {
    let btw : String
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
        .foregroundStyle(.white)
        .background(.black.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal,16)
        .padding(.vertical,8)
    }
}
