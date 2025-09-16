import SwiftUI

struct Oiteke: View {
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            ZStack{
            
                Color.ivory.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false){
                    
                    Text("1. 博打にのめり込む男")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("昔ある所に一人の男がおりました。その男は博打を覚えてしまいまったく働こうとしませんでした。家業もそっちのけで、毎日賭場に通う日々でした。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("2. 幼馴染みの心配")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("見兼ねた幼馴染みが何度も働くよう説得しましたが、男は全く聞き入れません。このままでは身を滅ぼすと心配し、ある計画を思いつきました。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("3. 危険な賭けの提案")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("幼馴染は男と賭けをすることにしました。「おいてけ堀」で夜釣りをして、魚を持って帰って来れたらもう何も言わないと約束したのです。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("4. おいてけ堀の噂")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("この街には「おいてけ堀」という堀がありました。夜釣りをすると「おいてけ〜…」という声がして、化け物が現れるという恐ろしい噂のある場所でした。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("5. 恐怖の夜釣り")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("その夜、男はおいてけ堀で釣りをしていました。静寂な夜の中、釣り糸を垂らしながら、噂の化け物など現れないだろうと高をくくっていました。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("6. 不気味な声")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("すると堀の方から「おいてけ〜…」という不気味な声が聞こえてきました。男はびっくりして逃げ出そうとしましたが、そこに一人の美しい若い女が現れたのです。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("7. のっぺらぼうの正体")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("女は男を見ると「今ここで釣った魚を置いて行ってください」と言って、自分の顔をはずしました。そこには何も無い、のっぺらぼうの顔があったのです。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("8. ソバ屋での恐怖")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("男がいつも通っている店へ逃げ込み、おやじに今のことを話しました。すると「それはこんな顔ではなかったか？」とおやじが振り返ると、その顔ものっぺらぼうでした。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("9. 家でも続く悪夢")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("男は釣った魚も何も放り出して家へ逃げ帰りました。女房が「お帰り」と言って振り返ると、女房の顔ものっぺら ぼうだったのです。男は恐怖のあまり気絶してしまいました。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("10. 友人たちの芝居")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("実は「おいてけ〜…」の声は幼馴染で、ソバ屋のおやじと男の女房は白粉を塗ってのっぺらぼうに化けていました。男を立ち直らせるため、みんなで一芝居打ったのです。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                      Text("11. 本当の化け物")
                          .font(.title2)
                          .fontWeight(.bold)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal,16)

                      HStack{
                          Text("しかし、あの美しい女性は誰も頼んでいませんでした。本当においてけ堀には化け物がいたのです。二人は青ざめ、男は心を入れ替えて真面目に働くようになったということです。")
                      }
                      .padding(20)
                      .frame(maxWidth: .infinity)
                      .background(Color(.white))
                      .cornerRadius(12)
                      .padding(.horizontal,16)

                    
                    
                }
                .padding(.top,18)
            }
            .navigationTitle("おいてけ掘")
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
