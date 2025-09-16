import SwiftUI

struct Zasikiwarasi: View {
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            ZStack{
                
                Color.ivory.edgesIgnoringSafeArea(.all)
    
                ScrollView(showsIndicators: false){
                    
                    Text("1. 東北の古い家")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        
                        Text("むかし、岩手や青森の山あいの村に、古くから立つ大きな家がありました。                             その家では、夜になると廊下を走る子どもの足音が聞こえることがありました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    Text("2. 子どもの姿")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        Text("ある晩、家の主人がふと座敷を見ると、赤い小袖を着た小さな子どもがちょこんと座っていました。                             「誰の子だろう？」と思った瞬間、ふっと消えてしまいました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    Text("3. 家に宿る守り神")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        Text("村人たちは「ああ、それは座敷わらしだ」と言いました。                             座敷わらしがいる家は栄え、商売も繁盛し、家族は幸せになると伝えられていたのです。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    
                    Text("4. 去っていく時")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        
                        Text("けれども、ある時期を境に足音も姿も消えてしまいました。                             すると不思議なことに、その家はだんだんと傾き、商売もうまくいかなくなっていったといいます。")
                            .padding(8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    Text("5. ありがたき存在")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        
                        Text("人々は「座敷わらしは、幸せを運んでくれる子どもの神さまのような存在なのだ」と噂しました。                             今も東北の古民家を訪れると、座敷わらしに会えたら幸運が訪れると信じられています。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                
                    
                }
                .padding(.top,18)
            }
            .navigationTitle("座敷わらし")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem{
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        
    }
    
}


