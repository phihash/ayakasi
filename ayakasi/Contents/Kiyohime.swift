import SwiftUI

struct Kiyohime: View {
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            ZStack{
            
                Color.ivory.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false){
                    
                    //1
                    Text("1. 若き僧の旅")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        
                        Text("平安時代、紀州熊野を目指す若い僧・安珍が旅をしていました。真面目で美しい容姿の彼は、多くの人々に注目される存在でした。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    Text("2.清姫との出会い")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                  
                        Text("旅の途中、安珍は日高川近くに住む清姫の家に宿を求めます。清姫は地主の娘で、美しいながらも情熱的な心を持っていました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    Text("3. 一目惚れ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("清姫は安珍の姿に一目で心を奪われます。夜更けまで言葉を交わすうちに、彼への恋心はますます募っていきました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    
                    Text("4. 禁欲と拒絶")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("しかし安珍は修行の身。「女人に心を許すことはできない」と、清姫の想いを断ち切ろうとします。ただ冷たく突き放すことはできず、「帰りにまた立ち寄る」と約束してしまいました。")
                            .padding(8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    Text("5. 裏切られた心")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                      
                        Text("ところが安珍は再び彼女に会うつもりはなく、約束を反故にして寺へと急ぎます。清姫はその気配を感じ取り、裏切られた思いで胸をかきむしられるような怒りに燃えました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    Text("6. 執念の追跡")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        
                        Text("「騙された！」                         清姫は走り、やがて人の力を超えた執念に突き動かされます。髪を振り乱し、裸足で野を駆け、やがてその姿は蛇へと変貌していきました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    Text("7. 日高川の激流")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("安珍は必死で日高川を船で渡ろうとします。けれども清姫は巨大な蛇と化し、川を泳ぎ渡り、火花を散らしながら彼を追いました。村人たちはその異様な姿に恐れ慄き、誰も止めることができませんでした。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    Text("8. 道成寺への逃げ込み")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("ついに安珍は道成寺に辿り着き、僧たちに助けを求めます。僧たちは彼を大きな鐘の中に隠し、清姫の追撃から守ろうとしました。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    Text("9. 炎の執念")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("やがて清姫は鐘の前に現れます。蛇の巨体で鐘に巻き付き、燃えさかる炎を吐きかけました。鐘は灼熱に包まれ、中に隠れた安珍は焼き殺されてしまいました。")
                            .padding(8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    Text("10. 破滅ののち")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("恋い焦がれた男を自らの手で死に追いやった清姫は、憎しみも恋心も飲み込んで炎の中に消えていきました。その姿は人のものではなく、執念に囚われた怪物そのものでした。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    Text("11. 伝説として残る")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,16)
                    HStack{
                        //                        Image("kappa")
                        //                            .resizable()
                        //                            .frame(width: 100, height: 100)
                        //                        Spacer()
                        Text("この悲劇はやがて「道成寺縁起」として語り継がれ、能・歌舞伎・浄瑠璃などに取り上げられました。清姫の恋は純粋でありながら、執念によって悲劇に変わり、今もなお人々に強い印象を残しています。")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                    
                    
                    
                    
                    
                }
                .padding(.top,18)
            }
            .navigationTitle("安珍清姫")
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
