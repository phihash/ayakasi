let ayakasis: [Ayakasi] = [
    Ayakasi(
        name: "アクロバティックサラサラ",
        documentId: "acrobaticsarasara",
        imageName: "https://i.imgur.com/5S0vJnU.png",
        description: "現代の怪談に登場する背の高い女の怪異。赤い服と帽子を身に着け、長い黒髪をサラサラとなびかせながら、奇妙なポーズで近づいてくるとされる。",
        categories: ["現代の怪","すべて"],
        btw: "名前が「悪皿（あくさら）」と略されることもある。",
        episodes: "深夜の道路脇で、看板の前にアクロバティックなポーズで立ちつくしている姿を見たという話。",
        sotry: false
    ),
    
    Ayakasi(
        name: "神虫",
        documentId: "sintyu",
        imageName: "https://i.imgur.com/flpwgn1.png",
        description: "巨大な虫のような姿で描かれる怪物。節くれだった体と多数の脚、翼や触角を持ち、うごめくだけで禍々しい気配を放つという。",
        categories: ["すべて"],
        btw: "古い絵巻物などに似た姿が描かれており、災いをもたらす存在として語られる。",
        episodes: "夜更けの里に現れ、家々の屋根を踏み抜きながら這い回ったため、人々が神社に逃げ込んだという話。",
        sotry: false
    ),
    Ayakasi(
        name: "ぬりかべ",
        documentId: "nurikabe",
        imageName: "https://i.imgur.com/k10aRdC.jpeg",
        description: "前進を阻む“壁”として感じられ、押しても避けても進めない。低い位置を叩くと消える、角を探すと抜けられるなどの対処譚が伝わる。",
        categories: ["道の怪","すべて"],
        btw: nil,
        episodes: "旅人が同じ場所をぐるぐる回らされる話",
        sotry: false
    ),
    Ayakasi(
        name: "傘小僧",
        documentId: "kasakozou",
        imageName: "https://i.imgur.com/CGqsVUE.png", // ここは適切な画像URLに置き換えてください
        description: "一本足で飛び跳ねる、古い唐傘の妖怪。目玉と長い舌を持ち、雨の夜に出現すると言われる。人々を驚かせることを好むが、悪さはしないとされる。",
        categories: ["道の怪","すべて"],
        btw: nil,
        episodes: "室町時代の絵巻物にも登場する",
        sotry: false
    )
    ,
    
    Ayakasi(
        name: "牛鬼",
        documentId: "usioni",
        imageName: "https://i.imgur.com/8plQ1rp.jpeg",
        description: "頭が牛で首から下は蜘蛛のような胴体、あるいはその逆の場合もある。人を襲うとされ、牛鬼が出現する前に、濡れ女が赤ん坊を抱かせようとしてくる。\n島根県で牛鬼の伝承が多い。",
        categories: ["水の怪","すべて"],
        btw: nil,
        episodes: "男が釣りから帰ろうとしたとき、濡女が現れて赤子を渡すと消えてしまった。\n赤子を離そうとしても、石のようになって手から離れず、その間に牛鬼があらわれ襲いかかろうとするが、なんとか逃げ切って助かったという伝承がある。\n",
        sotry: false
    ),
    
    Ayakasi(
        name: "件",
        documentId: "kudan",
        imageName: "https://i.imgur.com/ZWININ4.jpeg",
        description: "件（くだん）は、牛の体に人の顔を持ち、牛からうまれる。\n地域によって、下は牛以外にも馬・ヘビ・魚などの生き物であると伝えられる。\n件（くだん）は、牛からうまれたあとに、その年の吉報あるいは災いを予言し、数日ほどで死ぬと伝えられ、その予言は決して外れないと言われた。",
        categories: ["山の怪","すべて"],
        btw: "作家小松左京の、くだんのははという短編小説で題材にされている。",
        episodes: "具体的な逸話として、昔、牛からうまれた後に、「これから大変な世の中になるから、ヒエやアワなどの食料を蓄えるように」と告げ数日で死んだ。まもなくして、戦争が始まり、予言を告げられたものは食べ物に困らなかったという。\n ",
        sotry: false
    ),
    
    Ayakasi(
        name: "ぬらりひょん",
        documentId: "nurarihyon",
        imageName: "https://i.imgur.com/qkhjzxU.jpeg",
        description: "瓢箪のように長くつるりとした頭の老人。夜ふけに他人の家に上がり込み、茶を飲んだり家人を従わせたりするという。",
        categories: ["家の怪","すべて"],
        btw: nil,
        episodes: "夜に他人の家へ上がり込み主人のように振る舞う",
        sotry: false
    ),
    
    Ayakasi(
        name: "ろくろ首",
        documentId: "rokurokubi",
        imageName: "https://i.imgur.com/PmWwxUY.jpeg",
        description: "昼は普通の人の姿で暮らし、夜に首だけが伸びて彷徨うとされる。自覚のない型・自覚して人を脅かす型の両方が伝わる。",
        categories: ["道の怪","すべて"],
        btw: nil,
        episodes: "旅籠で寝ている間に首が伸び、別室を覗く話",
        sotry: false
    ),
    
    Ayakasi(
        name: "小豆洗い",
        documentId: "azukiarai",
        imageName: "https://i.imgur.com/Wns68r9.jpeg",
        description: "小豆洗い（あずきあらい）は川で小豆を洗う妖怪で、小豆とぎ（あずきとぎ）、小豆あらいど（あずきあらいど）など、様々な呼び名で全国的に分布している。\n小豆洗いは、川のほとりでシャキシャキと小豆をとぐ音が聞こえ、音をする方にいってもその姿はないといったものや、「小豆洗おか、人取って喰おか」など歌いながら小豆を洗うタイプもいる。",
        categories: ["音の怪","水の怪","すべて"],
        btw: "小豆は収獲後乾燥して保存した際のごみや虫を除くために洗います。",
        episodes: "「ショキショキ」「ザクザク」と豆を研ぐ音が続き、覗くと波紋だけが残っていたという怪談がある。",
        sotry: false
    ),
    Ayakasi(
        name: "影女",
        documentId: "kageonna",
        imageName: "https://i.imgur.com/qOqREju.png",
        description: "物の怪のいる家で、月影に照らされた女の姿の影が家の障子に映るものとされる",
        categories: ["家の怪","すべて"],
        episodes: "家の障子や窓に女の影が映り、庭先に姿を見せても家中には入らないと言われている。",
        sotry: false
    ),
  
    Ayakasi(
        name: "猫又",
        documentId: "nekomata",
        imageName: "https://i.imgur.com/oWCk6lj.jpeg",
        description: "長命の猫が尾を二つに分け、着物をまとって踊ったり三味線を弾いたりする。人に化けて家に入り込むこともある。",
        categories: ["動物の怪","すべて"],
        btw: nil,
        episodes: "夜更けに猫又が座敷で三味線を奏でた、という怪談が広く伝わる。",
        sotry: false
    ),
    
    Ayakasi(
        name: "狐",
        documentId: "kitsune",
        imageName: "https://i.imgur.com/IsPIXy5.jpeg",
        description: "人間や僧・美女などに化け、幻術や『狐火』で人を惑わす。九尾に至るほど霊力が高いとされる。",
        categories: ["動物の怪","すべて"],
        btw: nil,
        episodes: "夜道で美女に出会い家へ通ったが、翌朝見ると古い祠だった——という狐の嫁入話が多い。",
        sotry: false
    ),
    Ayakasi(
        name: "二口女",
        documentId: "futakuchionna",
        imageName: "https://i.imgur.com/ugHjdpW.png",
        description: "少食を装うが、もう一つの口で主に食べ物を摂取する。",
        categories: ["家の怪","すべて"],
        episodes: "人前では食事をせず、誰も居ない時に後ろの口でたくさん食べる「食わず女房」の話が有名である。",
        sotry: false
    ),
    Ayakasi(
        name: "百目鬼",
        documentId: "doumeki",
        imageName: "https://i.imgur.com/lIYjeST.png",
        description: "百目鬼(どうめき)とは腕や体に無数の目を持つ怪物",
        categories: ["道の怪","すべて"],
        episodes: "宇都宮では藤原秀郷によって退治されたという伝承がある。",
        sotry: false
    ),
    Ayakasi(
        name: "おおむかで",
        documentId: "oomukade",
        imageName: "https://i.imgur.com/pCB7BHG.png",
        description: "巨大なむかでの妖怪",
        categories: ["道の怪","すべて"],
        episodes: "藤原秀郷が瀬田の唐橋で横たわっている大蛇に頼まれて、おおむかでを退治した",
        sotry: false
    ),
    Ayakasi(
        name: "アマビエ",
        documentId: "amabie",
        imageName: "https://i.imgur.com/SdipUuu.png",
        description: "長い髪と鳥のようなくちばし、全身の鱗、三本の尾びれを持つとされる。恐れるよりも、人々を守る象徴として語られてきた。",
        categories: ["水の怪","すべて"],
        btw: nil,
        episodes: "疫病退散の護符として絵姿が流布",
        sotry: false
    ),
    
    
    Ayakasi(
        name: "うわん",
        documentId: "uwan",
        imageName: "https://i.imgur.com/VYr7nhI.jpeg",
        description: "画図百鬼夜行や百怪図巻などに描かれた妖怪。お歯黒で、3本指の先には鋭い爪がついている。名前の通り、うわんと大きな声で人を驚かす。",
        categories: ["音の怪","すべて"],
        btw: nil,
        episodes: "江戸時代、青森県の夫婦が古い屋敷に引っ越したその夜、「うわん」という大声が響いて一睡できなかった。\n近所の老人から「古い屋敷にはうわんという怪物が住んでいる」と聞いた。",
        sotry: false
    ),
    Ayakasi(
        name: "雪女",
        documentId: "yukionna",
        imageName: "https://i.imgur.com/TCnmIDA.jpeg",
        description: "白い着物に長い黒髪、透き通るような肌。地に足跡を残さず、静かに漂うように現れるとされる。",
        categories: ["家の怪","すべて"],
        btw: nil,
        episodes: "吹雪の夜の遭遇譚",
        sotry: true
    ),
    Ayakasi(
        name: "テケテケ",
        documentId: "teketeke",
        imageName: "https://i.imgur.com/RN94Yrq.jpeg",
        description: "上半身だけで地面を這いながら、“テケテケ”という音を立てて高速で迫る。見つかると逃げ切れないと言われ、出会った者に危害を加えるとされる。",
        categories: ["現代の怪","すべて"],
        btw: nil,
        episodes: "夜の線路や学校で“テケテケ”という音が響く",
        sotry: false
    ),
    Ayakasi(
        name: "人面犬",
        documentId: "jinmenken",
        imageName: "https://i.imgur.com/g69tYkw.jpeg",
        description: "犬の体に人間の顔をついた奇妙な姿。“ワンワン”としゃべる、バイクに乗っている、夜道を歩いているなどバリエーションは豊富。見た目は気味が悪いが、実害は少ないとも言われる。",
        categories: ["現代の怪","すべて"],
        btw: nil,
        episodes:"夜道で突然人間の顔をした犬に出会う",
        sotry: false
    ),
  
    Ayakasi(
        name: "一つ目小僧",
        documentId: "hitotsumekozou",
        imageName: "https://i.imgur.com/0nI87bj.png",
        description: "目が一つしかない小僧の妖怪",
        categories: ["道の怪","すべて"],
        episodes: "12月8日の晩になると人の目には見えない一つ目小僧が、戸締りされていない家をさがして入ってくるといわれてた。",
        sotry: false
    ),
    Ayakasi(
        name: "トイレの花子さん",
        documentId: "toirenohanakosan",
        imageName: "https://i.imgur.com/nWT8xfl.jpeg",
        description: "赤いジャンパースカートに白いシャツ、おかっぱ頭の小学生の女の子。ランドセルを背負っていることも多い。女子トイレの3番目の個室から現れるとされ、呼びかけると返事をしたり、いたずら好きな一面も。",
        categories: ["現代の怪","すべて"],
        btw: nil,
        episodes: "女子トイレの3番目の個室をノックすると返事がある",
        sotry: false
    ),
    Ayakasi(
        name: "のっぺらぼう",
        documentId: "nopperabou",
        imageName: "https://i.imgur.com/Sn07s1b.png",
        description: "ふつうの人型であるが、顔には目,鼻,耳,口がない妖怪",
        categories: ["道の怪","すべて"],
        btw: "現時点で、のっぺらぼうという言葉が記録された最初の文献は、松尾芭蕉の詠んだ句である",
        episodes: "おいてけ堀で釣った魚を持って帰ろうとすると、のっぺらぼうが現れ、逃げた先でも遭遇する。\nおいてけ堀の「おいてけ〜」という声の主は、河童とも言われており、おいてけ掘の舞台は、現在の錦糸町周辺とされる。",
        sotry: true
    ),
    Ayakasi(
        name: "清姫",
        documentId: "kiyohime",
        imageName: "https://i.imgur.com/ZcAiGcy.jpeg",
        description: "紀伊国の娘・清姫は安珍に恋い焦がれ、やがて蛇となって追い詰め、道成寺の鐘に隠れた安珍を炎で焼き滅ぼしたと語られる。人の情念が怪へと変ずる典型。",
        categories: ["動物の怪","すべて"],
        btw: nil,
        episodes: "安珍を追って蛇体に変ずる",
        sotry: true
    ),
    Ayakasi(
        name: "鵺",
        documentId: "nue",
        imageName: "https://i.imgur.com/7oEtFHB.jpeg",
        description: "鵺(ぬえ)とは頭が猿で胴が狸、手足は虎で尾は蛇の姿で、鵺の鳴き声は、夜中に不穏な声で鳴くトラツグミに似ているとされる。",
        categories: ["音の怪","すべて"],
        btw: "兵庫県西脇市の長明寺には、鵺退治像があります。",
        episodes: "都を騒がす鵺を退治するように命じられた源頼政が、夜に矢で射ったところ怪しいものが落ちた。\n火を灯してそれを見ると、頭は猿、体は狸、尾は蛇、手足は虎の姿をした妖怪がなくなっていたという話があり、その射った矢を洗ったのが鵺池とされる。\nそして、その死がいを丸木舟にのせて川に流したところ、最終的に芦屋に漂着した。\n祟りを恐れた村人たちは立派な墓をつくり、これが今日までに残る鵺塚である。",
        sotry: false
    ),
   
    Ayakasi(
        name: "濡れ女",
        documentId: "nureonna",
        imageName: "https://i.imgur.com/Von1CEd.jpeg",
        description: "長い黒髪と濡れた和服、青白い肌を持つ。哀しげな表情で現れ、川や沼のほとり、橋の上を歩く姿が多い。恐怖の象徴でありつつ、水難事故への警告とされることもある。",
        categories: ["水の怪","すべて"],
        btw: nil,
        episodes: "夜道で橋を渡っていると、濡れ女が現れ道をふさぐ",
        sotry: false
    ),
    
   
    Ayakasi(
        name: "すなかけばばあ",
        documentId: "sunakakebabaa",
        imageName: "https://i.imgur.com/AXzMxMo.jpeg",
        description: "背の曲がった老婆の姿で現れ、手にした杓や袋から砂を浴びせて人を惑わせるとされる。",
        categories: ["道の怪","すべて"],
        btw: nil,
        episodes: "砂をかけられ家の場所が分からなくなる話",
        sotry: false
    ),
    Ayakasi(
        name: "鬼",
        documentId: "oni",
        imageName: "https://i.imgur.com/TZNK6q6.jpeg",
        description: "赤や青の肌、虎皮の褌、手には金棒。残虐な怪として語られる一方、悪を懲らす存在や守護の側面が描かれることもある。",
        categories: ["山の怪","すべて"],
        btw: nil,
        episodes: "酒呑童子退治",
        sotry: false
    ),
    
    
    Ayakasi(
        name: "あかなめ",
        documentId: "akaname",
        imageName: "https://i.imgur.com/fmrL7Lm.jpeg",
        description: "やせぎすの体つきに乱れた髪、鋭い爪、異様に長い舌が特徴。夜更けに人が寝静まった頃、湿気のこもる場所に現れて汚れをなめ取るという。",
        categories: ["家の怪","すべて"],
        btw: nil,
        episodes: "掃除を怠る家に住みつくという戒め譚",
        sotry: false
    ),
    
    Ayakasi(
        name: "河童",
        documentId: "kappa",
        imageName: "https://i.imgur.com/IwK5a8g.jpeg",
        description:"カッパは、日本全国の川・池・沼・海などの水界に棲み、陸上も歩行する。カッパという呼称が一般的であるが、ガワタロ、メドチなど場所によっていろいろな呼び方がある。",
        categories: ["水の怪","すべて"],
        btw: nil,
        episodes: "カッパは、子供を溺死させたり、馬を川へ引きずり込んだり、田畑を荒らしたりするといった恐ろしい一面をもつ一方で、田植え、田の草取りの手伝いをしたり、命を助けてもらったお礼として人間に薬の製法を教えたりもするといったエピソードもある",
        sotry: false
        
    ),
    Ayakasi(
        name: "がしゃどくろ",
        documentId: "gashadokuro",
        imageName: "https://i.imgur.com/zAGYJpV.png",
        description: "家屋をも見下ろすほどの巨体の骸骨で、闇夜に現れて旅人を襲うとされる。顎を鳴らす音や不気味な気配とともに近づき、油断した者の首を噛みちぎるという。",
        categories: ["道の怪","すべて"],
        btw: nil,
        episodes: "夜中に“ガシャガシャ”と音を立てて徘徊する話",
        sotry: false
    ),
    
    Ayakasi(
        name: "いったんもめん",
        documentId: "ittanmomen",
        imageName: "https://i.imgur.com/st1YIN4.jpeg",
        description: "白い反物が生き物のようにたなびき、風に乗って飛ぶ。人の顔に巻きついたり、肩にまとわりついたりする挙動が語られる。",
        categories: ["道の怪","すべて"],
        btw: nil,
        episodes: "夜道で顔に巻きつき驚かせる話",
        sotry: false
    ),
    
   
    Ayakasi(
        name: "てんぐ",
        documentId: "tengu",
        imageName: "https://i.imgur.com/UT0Xazm.jpeg",
        description: "長い鼻の大天狗、鳥の嘴を思わせる烏天狗などの相。山風を操り、剣術・幻術に長けるとされる。",
        categories: ["山の怪","すべて"],
        btw: nil,
        episodes: "行者を試す／子をさらうといった試練譚",
        sotry: false
    ),
    
    Ayakasi(
        name: "うみぼうず",
        documentId: "umibouzu",
        imageName: "https://i.imgur.com/9NraCIb.jpeg",
        description: "海面から巨大な黒い僧形の影が現れ、船を揺らし、油を要求するなどの話型がある。桶を差し出し機先を制する対処譚も有名。",
        categories: ["水の怪","すべて"],
        btw: nil,
        episodes: "油を要求するが底抜けの桶で退ける話",
        sotry: false
    ),
    
  
    
    Ayakasi(
        name: "口裂け女",
        documentId: "kuchisakenna",
        imageName: "https://i.imgur.com/2Y4Vghp.jpeg",
        description: "長い黒髪とコート姿、顔の下半分をマスクや布で隠していることが多い。正体は不明だが、マスクを外すと口が耳まで大きく裂けている。怖がらせる存在として語られるが、対処法や撃退エピソードも有名。",
        categories: ["現代の怪","すべて"],
        btw: nil,
        episodes: "『私、きれい？』と問いかけられる",
        sotry: false
    ),
    
    Ayakasi(
        name: "わにゅうどう",
        documentId: "wanyuudou",
        imageName: "https://i.imgur.com/yIRXXnP.png",
        description: "燃える大車輪に苦悶の表情の頭部が付いた姿で夜道を転がる。見る者の魂を奪うとも子を攫うともいう。",
        categories: ["道の怪","すべて"],
        btw: nil,
        episodes: "深夜に子を攫う戒め話／正視してはならぬ話",
        sotry: false
    ),
    
    Ayakasi(
        name: "玉梓",
        documentId: "tamasusa",
        imageName: "https://i.imgur.com/awxxXQe.jpeg",
        description: "神余光弘の愛妾から山下定包の妻となった美女。里見義実に捕らえられ斬首される際、呪詛を残し怨霊化して里見家を祟る。",
        categories: ["家の怪","すべて"],
        btw: nil,
        episodes: "里見義実に斬首され呪いをかける",
        sotry: false
    ),
    
    Ayakasi(
        name: "やまんば",
        documentId: "yamanba",
        imageName: "https://i.imgur.com/52jeUB8.png",
        description: "乱れ髪に異様な力を持つ山姥。旅人を惑わし喰らう話の一方、子を授ける・助けるなど多面的な像を持つ。",
        categories: ["山の怪","すべて"],
        btw: nil,
        episodes: "山小屋に招き入れ翌朝に正体が露見する話",
        sotry: true
    ),
    
    Ayakasi(
        name: "座敷童",
        documentId: "zashikiwarashi",
        imageName: "https://i.imgur.com/4M0QBCe.png",
        description: "童子姿で家の中を走り回る気配を残す。姿が見えなくなると家運が傾くという俗信が広い。",
        categories: ["家の怪","すべて"],
        btw: nil,
        episodes: "姿を見た家が繁栄する／見えなくなると衰運の兆し",
        sotry: true
    ),
    
  
    
    Ayakasi(
        name: "かまいたち",
        documentId: "kamaitachi",
        imageName: "https://i.imgur.com/DA4BdY7.jpeg",
        description: "かまいたちは、外見はイタチに似ると考えられる一方、実際には人間の目には見えないともされる。また、痛みを感じないうちに深い傷を負わせるが、そのわりには出血はしない現象を指す。",
        categories: ["動物の怪","すべて"],
        btw: nil,
        episodes: "岐阜県の飛騨地方などでは、かまいたちは三人の神様と考えられる。\n最初の神様がぶつかって人を転ばせ、二番目の神様が切りつけ、三番目の神様が薬をつけて治す。よって、鎌で切ったような傷の形をしていながら、出血や痛みがないとされる。",
        sotry: false
    )
]
