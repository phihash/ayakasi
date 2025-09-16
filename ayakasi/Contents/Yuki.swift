import SwiftUI

struct Yuki: View {
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            ZStack{
                
                Color.ivory.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false){
                    
                    
                    Text("1. 冬の夜の出来事")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        
                        Text("ある雪の深い夜、木こりの親子は山中で猛吹雪に遭い、小屋へ避難しました。                             そこで二人を訪れたのが、真っ白な着物に身を包み、氷のように冷たい息を持つ「雪女」でした。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    Text("2. 息子への慈悲")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        Text("雪女は父をその冷気で殺してしまいますが、若い息子には「このことを誰にも話さなければ命を助ける」と言い残し、消えていきました。息子は恐怖に震えながらも、その約束を心に刻みます。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    Text("3. 美しい娘との出会い")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("しばらくして、息子は「お雪」という名の美しい娘と出会い、やがて夫婦となります。                             二人の生活は幸せに満ち、子どもにも恵まれました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    
                    Text("4. 禁じられた告白")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        
                        Text("ある冬の晩、息子はふとあの夜の出来事を思い出し、妻に語ってしまいます。                             「昔、雪女に出会って父を殺され、命を助けられたんだ……」")
                            .padding(8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    Text("5. 正体の発覚")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        
                        Text("それを聞いた妻は顔色を変え、次の瞬間に姿を変えました。                             「約束を破るとは……私はその雪女だ」                             お雪は子どもたちを思い出し、「子どもたちがいるから今日は命を奪わない」と言い残し、吹雪の夜に消えていきました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    Text("6.その後")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        
                        Text("雪女は二度と現れず、残されたのは子どもたちと、深い雪の記憶だけでした。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                }
                .padding(.top,18)
            }
            .navigationTitle("雪女")
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


