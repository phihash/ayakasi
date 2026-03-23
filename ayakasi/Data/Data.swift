import MapKit

let ayakasis: [Ayakasi] = [
    Ayakasi(
        name: "枕返し",
        documentId: "makuragaesi",
        imageName: "https://i.imgur.com/kd5wwgm.png",
        imageSource: "パブリックドメイン",
        description: "夜中に寝ている人の枕をひっくり返したり、頭と足の向きを変えたりする妖怪。小さな坊主や仁王のような姿で描かれることが多い。東北        地方では座敷童子の悪戯ともいわれる。かつては枕に人の魂が宿ると信じられており、枕を返されることは死を意味するとして恐れられていたが、徐々に        その信仰が廃れ、単なる悪戯と見なされるようになった",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        searchKeywords: ["まくら", "マクラ", "枕", "まくらがえし", "まくらこぞう", "枕小僧", "ざしきわらし", "座敷童子", "いたずら", "悪戯","寝る", "睡眠", "夜"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "大雄寺",
                coordinate: CLLocationCoordinate2D(latitude: 36.86583557069369, longitude: 140.1226900441809),
                description: "江戸時代から伝わる「枕返しの幽霊」という掛け軸がある寺。この掛け軸の前で眠ると、翌朝には枕が返されているという伝承が残る。坐禅や写経の体験もできる。",
                yokaiIds: ["makuragaesi"],
                prefecture: "栃木県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "オッパショ石",
        documentId: "oppasho_ishi",
        imageName: "https://i.imgur.com/3tBMuPN.png",
        description: "徳島の市街地近くの墓地にある、「おっぱしょ」と声を掛けて人をおどかす怪石。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        references: nil,
        searchKeywords: ["オッパショ石", "おっぱしょ", "オッパショいし", "徳島", "とくしま", "徳島県", "怪石", "かいせき", "石", "いし", "力士", "墓地", "道の怪"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "オッパショ石",
                coordinate: CLLocationCoordinate2D(latitude: 34.05645998373413, longitude: 134.54422761534468),
                description: "徳島の市街地近くの墓地にある怪石の伝承地",
                yokaiIds: ["oppasho_ishi"],
                prefecture: "徳島県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "アマビエ",
        documentId: "amabie",
        imageName: "https://i.imgur.com/jK10Hbs.png",
        imageSource: "パブリックドメイン",
        description: "1846年、肥後の海に現れた半人半魚の妖怪。長い髪と鳥のくちばしを持ち、豊作や疫病などの予言を伝えて、海にもどったという言い伝えがある。",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        searchKeywords: ["あまびえ", "アマビエ", "熊本", "くまもと", "熊本県", "肥後", "ひご", "大島子諏訪神社", "予言", "よげん", "疫病", "コロナ", "COVID-19", "水の怪", "海", "人魚", "件", "くだん", "天草"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "大島子諏訪神社",
                coordinate: CLLocationCoordinate2D(latitude: 32.477377901069154, longitude: 130.26318643678658),
                description: "天草・島原の戦い初戦地として知られる歴史ある神社。令和2年、コロナ禍における疫病終息を願い、アマビエの石神が鎮座された。",
                yokaiIds: ["amabie"],
                prefecture: "熊本県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "あかなめ",
        documentId: "akaname",
        imageName: "https://i.imgur.com/1kUq6RO.png",
        imageSource: "パブリックドメイン",
        description: "あかなめは、風呂場で桶の垢を舐める妖怪。これといって大きな害はない。風呂場を清潔にすれば、垢も発生しないため、あかなめには教訓が含まれているという説もある。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        searchKeywords: ["教訓","ふろ","垢","あかなめ","桶","おけ"],
        story: false
    ),
    Ayakasi(
        name: "べとべとさん",
        documentId: "betobetosan",
        imageName: "https://i.imgur.com/0FWOWRm.png",
        description:"べとべとさん",
        categories: ["音の怪","すべて"],
        relatedCategory: "音の怪",
        searchKeywords: ["べとべとさん"],
        story: false
    ),
    Ayakasi(
        name: "おとろし",
        documentId: "otorosi",
        imageName: "https://i.imgur.com/fNhSHPs.png",
        imageSource: "パブリックドメイン",
        description:"おとろし",
        categories: ["詳細不明","すべて"],
        relatedCategory: "詳細不明",
        searchKeywords: ["おとろし"],
        story: false
    ),
    Ayakasi(
        name: "タツクチナワ",
        documentId: "tatukutinawa",
        imageName: "https://i.imgur.com/E16AQO6.png",
        description: "タツクチナワ",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        searchKeywords: ["北九州","きたきゅうしゅう"],
        story: false
    ),
    Ayakasi(
        name: "たんたんころりん",
        documentId: "tantankorori",
        imageName: "https://i.imgur.com/ZqCkjAK.png",
        description:"仙台に伝わる妖怪。古い柿の木が実を収穫せずに放置すると出るといわれる",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["たんたんころりん","柿","仙台","宮城","かき","みやぎ"],
        story: false
    ),
    Ayakasi(
        name: "天井下り",
        documentId: "tenjokudari",
        imageName: "https://i.imgur.com/13jR5iS.png",
        imageSource: "パブリックドメイン",
        description: "天井下り",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        searchKeywords: ["てんじょうくだり"],
        story: false
    ),
    Ayakasi(
        name: "のづち",
        documentId: "noduti",
        imageName: "https://i.imgur.com/dMZX8Jr.png",
        description: "のづち",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["のづち"],
        story: false
    ),
    Ayakasi(
        name: "ぶるぶる",
        documentId: "buruburu",
        imageName: "https://i.imgur.com/MqIxaMR.png",
        description: "今昔画図続百鬼に描かれている妖怪。恐怖で人間がぞくっと震えるのは、ぶるぶるが取り憑くためだといわれる。",
        categories: ["詳細不明","すべて"],
        relatedCategory: "詳細不明",
        searchKeywords: ["鳥山石燕","今昔画図続百鬼"],
        story: false
    ),
    Ayakasi(
        name: "しろうかり",
        documentId: "siroukari",
        imageName: "https://i.imgur.com/pSFU2pT.png",
        imageSource: "パブリックドメイン",
        description: "百鬼夜行絵巻をはじめとした、絵巻物に描かれている妖怪\n白くて細長い妖怪で詳細は不明",
        categories: ["詳細不明","すべて"],
        relatedCategory: "詳細不明",
        searchKeywords: ["ばけ物つくし帖","百物語化絵絵巻","百鬼夜行絵巻","尾田郷澄","江戸時代"],
        story: false
    ),
    Ayakasi(
        name: "三尸",
        documentId: "sansi",
        imageName: "https://i.imgur.com/Lc1ltMW.png",
        description: "三尸(さんし)",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["さんし"],
        story: false
    ),
    Ayakasi(
        name: "家鳴",
        documentId: "yanari",
        imageName: "https://i.imgur.com/cNnAzKh.png",
        description: "家鳴(やなり)",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["やなり","家鳴"],
        story: false
    ),
    Ayakasi(
        name: "びわぼくぼく",
        documentId: "biwabokuboku",
        imageName: "https://i.imgur.com/8XORrJO.png",
        imageSource: "パブリックドメイン",
        description: "琵琶牧々（びわぼくぼく)",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["びわぼくぼく","琵琶"],
        story: false
    ),
    Ayakasi(
        name: "ひゃくもく",
        documentId: "hyakumoku",
        imageName: "https://i.imgur.com/7HzojTV.png",
        description: "ひゃくもく",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["ひゃくもく","百"],
        story: false
    ),
    Ayakasi(
        name: "みこしにゅうどう",
        documentId: "mikosinyuudou",
        imageName: "https://i.imgur.com/GyqfXnb.png",
        imageSource: "パブリックドメイン",
        description: "夜道を歩いていると僧の姿で突然現れ、はじめは小さな背丈だが見上げれば見上げるほど大きくなるという妖怪。全国各地に伝承があり、入道が大きくなるのを見上げると、喉を噛み切られるという言い伝えがある。「みこしにゅうどう見抜いた」と言えば消え去るという。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["宿直草","煙霞奇談","みあげにゅうどう","江戸時代","ノビアガリ","シダイダカ"],
        story: false
    ),
    Ayakasi(
        name: "がごぜ",
        documentId: "gagoze",
        imageName: "https://i.imgur.com/7ZlvwAJ.png",
        imageSource: "パブリックドメイン",
        description: "がごぜ",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["元興寺","奈良"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "元興寺",
                coordinate: CLLocationCoordinate2D(latitude: 34.67810978190381, longitude: 135.8314418711626),
                description: "飛鳥時代に元興寺に現れた妖怪。『日本霊異記』に記された鬼退治の伝説で知られ、境内には5体の小鬼の像が潜んでいる。",
                yokaiIds: ["gagoze"],
                prefecture: "奈良県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "ぬっぺっぽう",
        documentId: "nuppeppou",
        imageName: "https://i.imgur.com/5rTFb9l.png",
        description: "ぬっぺっぽう",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["ぬっぺっぽう"],
        story: false
    ),
    Ayakasi(
        name: "泥田坊",
        documentId: "dorotabou",
        imageName: "https://i.imgur.com/bHPMhnP.png",
        description: "泥田坊(どろたぼう)",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["どろたぼう"],
        story: false
    ),
    Ayakasi(
        name: "火車",
        documentId: "kasya",
        imageName: "https://i.imgur.com/q3Qa2wl.png",
        description: "火車(かしゃ)",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["猫","火車","かしゃ"],
        story: false
    ),
    Ayakasi(
        name: "だいだらぼっち",
        documentId: "daidarabotti",
        imageName: "https://i.imgur.com/XNQ5ovy.png",
        imageSource: "パブリックドメイン",
        description: "日本各地に伝わる巨人伝説。山を作り、谷を掘り、巨大な足跡が湖になったとされる。地域によって「デイダラボッチ」「ダイダラボウ」など呼び方が異なる。",
        categories: ["山の怪","すべて"],
        relatedCategory: "山の怪",
        searchKeywords: ["だいだらぼっち", "ダイダラボッチ", "デイダラボッチ", "ダイダラボウ", "でいだらぼっち", "巨人", "きょじん", "山", "やま", "山の怪", "山梨", "やまなし", "山梨県", "山梨岡神社", "石森山", "足跡", "湖"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "山梨岡神社",
                coordinate: CLLocationCoordinate2D(latitude: 35.67921691481622, longitude: 138.69168615581916),
                description: "平地に浮かぶ石森山に鎮座する神社。だいだらぼっちが作ったという伝承が残り、巨石群や奇岩が立ち並ぶ。躑躅の名所としても知られる。",
                yokaiIds: ["daidarabotti"],
                prefecture: "山梨県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "ヤマタノオロチ",
        documentId: "yamatanooroti",
        imageName: "https://i.imgur.com/QVnoJHi.png",
        imageSource: "パブリックドメイン",
        description: "ヤマタノオロチ",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["ヤマタノオロチ","やまたのおろち","八岐大蛇","オロチ","蛇","ヘビ","へび","大蛇","8つの頭","八つ頭"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "船通山",
                coordinate: CLLocationCoordinate2D(latitude: 35.156637675418914, longitude: 133.17866874603408),
                description: "斐伊川の源流にある山。スサノオノミコトがヤマタノオロチを退治した出雲神話の舞台として知られる。",
                yokaiIds: ["yamatanooroti"],
                prefecture: "島根県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "一本だたら",
        documentId: "ippondatara",
        imageName: "https://i.imgur.com/xDk7DJb.png",
        description: "一本だたら(いっぽんだたら)",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["1本","いっぽんだたら","一本足","一つ目","1つ目","一眼一足","山の妖怪","鍛冶","イッポンダタラ"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "果無山脈",
                coordinate: CLLocationCoordinate2D(latitude: 33.910530545321635, longitude: 135.74460219642324),
                description: "一本足で目が皿のような妖怪が現れる山脈。普段は無害だが、旧暦12月20日の『果ての二十日』には人を襲うと恐れられた。",
                yokaiIds: ["ippondatara"],
                prefecture: "奈良県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "般若",
        documentId: "hannya",
        imageName: "https://i.imgur.com/vJLMuL6.png",
        description: "般若(はんにゃ)",
        categories: ["すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["はんにゃ"],
        story: false
    ),
    Ayakasi(
        name: "蟹坊主",
        documentId: "kanibouzu",
        imageName: "https://i.imgur.com/dAnN6cU.png",
        description: "蟹坊主(かにぼうず)",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["かに"],
        story: false
    ),
    Ayakasi(
        name: "油すまし",
        documentId: "aburasumasi",
        imageName: "https://i.imgur.com/Ryo1n0t.png",
        description: "油すまし",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["あぶらすまし", "アブラスマシ", "油盗み", "あぶらぬすみ", "熊本", "くまもと", "河内", "かわち", "墓"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "妖怪「油すまし」の墓",
                coordinate: CLLocationCoordinate2D(latitude: 32.445623276269785, longitude: 130.31227092831656),
                description: "熊本県栖本町河内地区に残る油すましの墓とされる石像。地元では古くから妖怪伝承が語り継がれており、現在も地域の人々によって大切に管理されている。",
                yokaiIds: ["aburasumasi"],
                prefecture: "熊本県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "土蜘蛛",
        documentId: "tutigumo",
        imageName: "https://i.imgur.com/92Rbhpz.png",
        description: "土蜘蛛(つちぐも)",
        categories: ["すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["つちぐも"],
        story: false
    ),
    Ayakasi(
        name: "ほうこう",
        documentId: "houkou",
        imageName: "https://i.imgur.com/KcZayuW.png",
        description: "彭侯(ほうこう)",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["彭侯","中国","外国の妖怪"],
        story: false
    ),
    Ayakasi(
        name: "応声虫",
        documentId: "ousei",
        imageName: "https://i.imgur.com/tlw9Ehh.png",
        description: "応声虫",
        categories: ["すべて"],
        relatedCategory: nil,
        searchKeywords: ["応声虫"],
        story: false
    ),

    Ayakasi(
        name: "くねゆすり",
        documentId: "kuneyusuri",
        imageName: "https://i.imgur.com/r0uunaR.png",
        description: "くねゆすり",
        categories: ["音の怪","すべて"],
        relatedCategory: "音の怪",
        searchKeywords: ["くねゆすり", "秋田","仙北市"],
        story: false
    ),
    Ayakasi(
        name: "白虎",
        documentId: "byakko",
        imageName: "https://i.imgur.com/ydebR4R.png",
        description: "白虎",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["びゃっこ", "中国"],
        story: false
    ),
    Ayakasi(
        name: "青龍",
        documentId: "seiryu",
        imageName: "https://i.imgur.com/Ch5JFEO.png",
        description: "青龍",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["せいりゅう", "中国"],
        story: false
    ),
    Ayakasi(
        name: "朱雀",
        documentId: "suzaku",
        imageName: "https://i.imgur.com/oRDLTjr.png",
        description: "朱雀",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["すざく", "中国"],
        story: false
    ),
    Ayakasi(
        name: "玄武",
        documentId: "genbu",
        imageName: "https://i.imgur.com/GiVFGKQ.png",
        description: "玄武",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["げんぶ", "中国"],
        story: false
    ),
    Ayakasi(
        name: "波蛇",
        documentId: "namihebi",
        imageName: "https://i.imgur.com/Xi9meFI.png",
        description: "波蛇",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["波蛇", "なみへび"],
        story: false
    ),
    Ayakasi(
        name: "蟹鬼",
        documentId: "kanioni",
        imageName: "https://i.imgur.com/4OJ8ZhN.png",
        description: "かにおに",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["蟹鬼", "かにおに"],
        story: false
    ),
    Ayakasi(
        name: "キョンシー",
        documentId: "kyonsi",
        imageName: "https://i.imgur.com/RhjvBmt.png",
        description: "キョンシー",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["キョンシー", "中国"],
        story: false
    ),
    Ayakasi(
        name: "じゅうめん",
        documentId: "jumen",
        imageName: "https://i.imgur.com/ibPZzTI.png",
        description: "じゅうめん",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["じゅうめん"],
        story: false
    ),
    Ayakasi(
        name: "うやうやし",
        documentId: "uyauyasi",
        imageName: "https://i.imgur.com/CLaOoRo.png",
        description: "うやうやし",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["うやうやし"],
        story: false
    ),
    Ayakasi(
        name: "にくらし",
        documentId: "nikurasi",
        imageName: "https://i.imgur.com/KY1Qxgg.png",
        description: "にくらし",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "馬肝入道",
        documentId: "bakkannyudou",
        imageName: "https://i.imgur.com/4Nlpvq7.png",
        description: "馬肝入道",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "なんじやか",
        documentId: "nanjiyaka",
        imageName: "https://i.imgur.com/z3MAS9i.png",
        description: "",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "まっぴら",
        documentId: "mappira",
        imageName: "https://i.imgur.com/Bq5cPyz.png",
        description: "",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "ごたいめん",
        documentId: "gotaimen",
        imageName: "https://i.imgur.com/wQ6lOM0.png",
        description: "ごたいめんは、夜道や辻などで突然人の前に現れるとされる妖怪で、その名の通り「真正面から出会う」ことを特徴としている。振り返った先や道の曲がり角に、いつの間にか立っている姿が語られ、逃げようとしても進路を塞ぐように再び正面に現れるという。害を加えるわけではないが、道を進む者に強い動揺と不安を与え、夜道での不意の遭遇そのものを象徴する妖怪だと考えられている。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "いが坊",
        documentId: "igabou",
        imageName: "https://i.imgur.com/NqgfquS.png",
        description: "いが坊は、夜の道ばたや林の近くに現れるとされる小さな妖怪で、いがいがした姿をした坊主のように語られている。道の端にじっと座っていたり、転がっているように見えることもあり、人が近づくと急に姿を消すことが多い。害をなすことはほとんどなく、旅人や通行人を驚かせる程度の存在で、夜道で感じる気配や違和感が形になった妖怪だと考えられている。",
        categories: ["すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "べか太郎",
        documentId: "bekatarou",
        imageName: "https://i.imgur.com/GYL8nlN.png",
        description: "べか太郎は、夜道や人通りの少ない道に現れるとされる妖怪で、遠くから見ると人影のように見えるが、近づくと正体が分からなくなる存在だと語られている。追いかけても逃げることはなく、かといって捕まえることもできず、気づけばいつの間にか姿を消している。特別な害を及ぼすわけではないが、夜道で感じる不安や錯覚を形にした妖怪だと考えられている。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "わいら",
        documentId: "waira",
        imageName: "https://i.imgur.com/r9ld7sZ.png",
        imageSource: "パブリックドメイン",
        description: "わいらは、家の縁の下や暗がりに潜むとされる妖怪で、人目につかない場所からじっと人を見つめている存在だと語られている。はっきりとした姿や性質は伝わっておらず、影のように現れては気配だけを残し、特別な害をなすことも少ない。その正体の曖昧さゆえに、「そこに何かいるのではないか」という不安や違和感そのものが、わいらの正体だとも考えられている。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "ぬらりひょん",
        documentId: "nurarihyon",
        imageName: "https://i.imgur.com/l2lnRiI.png",
        imageSource: "パブリックドメイン",
        description: "ぬらりひょんは、夕暮れ時に人の家へ何食わぬ顔で上がり込み、まるで主のように振る舞うとされる妖怪である。老人のような姿をしているが、正体や目的ははっきりせず、追い出そうとしても気づけばいつの間にか消えているという。特別な害をなすわけではないが、その得体の知れなさと図々しさから、家に忍び込む怪異の代表的存在として語られてきた。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        story: false
    ),

    Ayakasi(
        name: "灰坊主",
        documentId: "akubouzu",
        imageName: "https://i.imgur.com/UMP1Qnv.png",
        description: "灰坊主（あくぼうず）は、囲炉裏や竈の灰の中から現れるとされる妖怪で、秋田県や岩手県などに伝わる。姿は灰まみれの坊主のように描かれ、ぬっと這い出て人を驚かせたり、夜に家の中をうろつくともいわれる。名前の通り「灰」に関わる怪異であり、火の気が消えた後の囲炉裏に残る灰の不気味さが、その伝承の背景にあると考えられている。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        searchKeywords: ["秋田","岩手","あくぼうず"],
        story: false
    ),
    Ayakasi(
        name: "獏",
        documentId: "baku",
        imageName: "https://i.imgur.com/A7VRMHF.png",
        description: "獏は、人の見る悪夢を食らうとされる霊獣で、中国由来の想像上の動物が日本に伝わったものと考えられている。象の鼻、熊の足、牛の尾など複数の動物の特徴を併せ持つ姿で描かれることが多い。夜ごと夢を荒らす邪気を払い、安眠をもたらす存在として、枕元に絵や像を置く風習もあった。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["ばく", "悪夢"],
        story: false
    ),
    Ayakasi(
        name: "馬癇",
        documentId: "umakan",
        imageName: "https://i.imgur.com/MnbUKMp.png",
        description:"馬癇(うまかん)は人の体内に棲み病を引き起こす病虫の一種。『針聞書』では赤い体に白い足を持つ馬の姿で描かれ、心臓に生じる癇の虫とされ、針術による治療が有効と記されている。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["馬", "うまかん"],
        story: false
    ),
    Ayakasi(
        name: "牛癇",
        documentId: "gyuukan",
        imageName: "https://i.imgur.com/52KBEw8.png",
        description: "牛癇(ぎゅうかん)は、人の体内に生じて病を引き起こすと考えられた病虫の一種。戦国期の医書『針聞書』には黒い角を持つ牛の姿で描かれ、肺に発生して食事の際に癇の症状を起こすとされ、鍼による治療が記されている。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["牛", "ぎゅうかん"],
        story: false
    ),
    Ayakasi(
        name: "野衾",
        documentId: "nobusuma",
        imageName: "https://i.imgur.com/6f5AJml.png",
        description: "ノブスマ（野衾）は、夜道を歩く人の前に壁のように立ちふさがる現象型の妖怪。上下左右に果てがなく進退を失わせ、恐怖や不安を増幅させるが、腰を下ろして落ち着くと消えると伝えられる。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["ふすま", "のぶすま","野衾"],
        story: false
    ),

    Ayakasi(
        name: "刑天",
        documentId: "keiten",
        imageName: "https://i.imgur.com/LwXUPb6.png",
        imageSource: "パブリックドメイン",
        description: "刑天は中国神話に登場する怪異的存在で、黄帝に敗れ首を失っても滅びず、胸を目、臍を口として斧と盾を手に戦い続けたとされる。勝敗を超え、闘争そのものに囚われた執念の象徴として語られる。",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["中国", "けいてん","刑天"],
        story: false
    ),
    Ayakasi(
        name: "孫悟空",
        documentId: "songokuu",
        imageName: "https://i.imgur.com/9fW3FIj.png",
        description: "孫悟空",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["中国", "西遊記","そんごくう"],
        story: false
    ),
    Ayakasi(
        name: "猪八戒",
        documentId: "chohakkai",
        imageName: "https://i.imgur.com/y0L0nPm.png",
        description: "『西遊記』に登場する妖怪。もとは天界で天蓬元帥という武将の位にあったが、酒に酔って月宮の仙女に無礼を働いた罪により下界へ落とされた。転生の途中で道を誤り、人間ではなく豚の姿をした半妖として生まれ変わったとされる。\n\n人里近くの高老荘に住みつき、力仕事をしながらも、食欲と色欲に忠実で怠け者な性質から周囲を困らせていた。見た目は大柄で腹が出ており、鼻面は豚そのものだが、人の言葉を話し、農具を武器として振るうほどの怪力を持つ。欲深く弱音を吐きやすい一方で、どこか憎めない存在として語られることが多い。\n\n後に三蔵法師一行と出会い、観音菩薩の取りなしによって旅の供となる。修行僧としては未熟で、しばしば逃げ腰になるものの、危機の際には力仕事を引き受けるなど、実務的な役割を果たしたとされる。人間的な煩悩を色濃く残した妖怪として、沙悟浄とは対照的な存在である。",
        categories: ["外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["中国", "西遊記","猪八戒","ちょはっかい"],
        story: false
    ),
    Ayakasi(
        name: "沙悟浄",
        documentId: "sagojou",
        imageName: "https://i.imgur.com/Eb4JLmi.png",
        description: "『西遊記』に登場する妖怪。もとは天界に仕える存在であったが、天帝の宴の席で誤って玻璃の杯を壊した罪により下界へ落とされ、流砂河に追放されたとされる。以後、七日に一度、天から降ってくる剣によって脇腹を刺されるという罰を受け続け、水辺に棲む水怪と成り果てた。\n\n流砂河では、通りかかった旅人や僧を襲い、その骸骨を首にかけていたと伝えられる。首に下げた骸骨は七つあり、これは自身に科せられた七日の刑を象徴するとも言われる。髪はまばらで、痩せた体つきの異様な姿をしており、人の言葉を解しながらも長く孤独な日々を送っていたという。\n\n後に三蔵法師一行と出会い、観音菩薩の導きによって改心し、旅の供として加わることになる。それまでは恐れられる水の怪であったが、根は真面目で従順な性質であり、過去の罪を背負いながらも黙々と役目を果たす存在として語られる。",
        categories: ["水の怪","外国の妖怪","すべて"],
        relatedCategory: "外国の妖怪",
        searchKeywords: ["西遊記", "中国","沙悟浄","さごじょう"],
        story: false
    ),
    Ayakasi(
        name: "しおふき",
        documentId: "siohuki",
        imageName: "https://i.imgur.com/L5i1unD.png",
        description: "江戸時代の妖怪絵巻『化け物尽くし絵巻』などに描かれる海の怪異。海面から細長い胴を伸ばし、象の鼻のような口先から潮を高く噴き上げるとされる。姿を見た者は、遠くからでも異様な水柱に気づくが、近づくほど正体がつかめず不気味だという。\n\n海辺で漁をしていた人々が、沖合に不自然に高い潮の噴き上がりを見つけた。最初は鯨の潮吹きだと思って船を出したが、近づくほど霧のような飛沫だけが増え、波間から細長い影が一瞬だけ立ち上がったという。影は象の鼻のような口先でさらに潮を噴き、あたりを白く霞ませたのち、何事もなかったかのように海へ沈んで消えた。以来、その海域では『潮の柱が立ったら近づくな』と語られるようになった。",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        story: false
    ),
    Ayakasi(
        name: "さとり",
        documentId: "satori",
        imageName: "https://i.imgur.com/0TvCDKX.png",
        description: "人の心を読む能力を持つとされる山の妖怪。胸に大きな目を持ち、出会った相手の内心を言い当てて動揺させると伝えられる。\n\n山中で出会った旅人の考えを次々と言い当て、恐怖のあまり逃げ出させたという話が残る。",
        categories: ["山の怪","動物の怪","すべて"],
        relatedCategory: "動物の怪",
        story: false
    ),
    Ayakasi(
        name: "くねくね",
        documentId: "kunekune",
        imageName: "https://i.imgur.com/BlDlQs5.png",
        description: "山間部や田畑の遠景に現れる、真っ白な人型のような異形。正体を凝視した者は発狂するとされ、詳細を認識してはならない存在として語られる。\n\n白い人影を望遠鏡で覗いた人物が正気を失った、という体験談がインターネット上で拡散された。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        searchKeywords: ["くねくね","都市伝説"],
        story: false
    ),
    Ayakasi(
        name: "すねこすり",
        documentId: "sunekosuri",
        imageName: "https://i.imgur.com/0kMuhjp.png",
        description: "雨の夜、足元をふいに横切る小さな影。すねに柔らかく身を擦り寄せ、歩幅を乱して人をたじろがせる。悪意は薄く、驚かせては霧のように消えると伝わる。\n\n暗闇の中で足元にまとわりつき、人を驚かせる。",
        categories: ["すべて"],
        relatedCategory: nil,
        story: false
    ),
    Ayakasi(
        name: "吸血鬼",
        documentId: "vampire",
        imageName: "https://i.imgur.com/Jk0nTE9.png",
        imageSource: "パブリックドメイン",
        description: "夜に現れ、人の血を吸うとされる怪異。コウモリと関連し、影のように忍び寄る存在として語られる。\n\n日光を嫌い、夜に活動する。血を吸われると吸血鬼になるとも言われる。",
        categories: ["すべて"],
        relatedCategory: nil,
        searchKeywords: ["吸血鬼"],
        story: false
    ),
    Ayakasi(
        name: "メリーさん",
        documentId: "merry",
        imageName: "https://i.imgur.com/kiz17nF.png",
        description: "電話で『いま○○にいるの』と居場所を知らせながら徐々に接近してくる人形の怪異。最後は背後に現れるとされる。\n\n電話の度に居場所が近づく。最後は『いま、あなたの後ろにいるの』と言う。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        story: false
    ),
    Ayakasi(
        name: "八尺様",
        documentId: "hachishakusama",
        imageName: "https://i.imgur.com/wjdcFZ9.png",
        description: "背丈が八尺（約240cm）あるとされる異様に背の高い女性の怪異。「ポポポ…」という声とともに現れ、人に憑くとされる。\n\n長身の影が遠くから近づいてくる。憑かれた者を狙うとされる。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        story: false
    ),
    Ayakasi(
        name: "隙間女",
        documentId: "sukimaonna",
        imageName: "https://i.imgur.com/ds8JAyn.png",
        description: "押し入れや家具、壁の狭い隙間などから覗き込む女性の怪異。細い空間に潜み、じっとこちらを見つめる。\n\n隙間に潜んで視線を送ってくる。視線が合うと近づいてくると言われる。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        story: false
    ),
    Ayakasi(
        name: "人魂",
        documentId: "hitodama",
        imageName: "https://i.imgur.com/oY0NygQ.png",
        description: "死者の霊が灯火のように漂うとされる怪異。夜道や墓地にふわりと浮かび、青白い炎の姿で現れる。\n\n夜間に漂い、人を驚かせる。怪異の前触れとされることもある。",
        categories: ["すべて"],
        relatedCategory: nil,
        story: false
    ),
    Ayakasi(
        name: "アクロバティックサラサラ",
        documentId: "acrobaticsarasara",
        imageName: "https://i.imgur.com/5S0vJnU.png",
        description: "都市伝説談に登場する背の高い女の怪異。赤い服と帽子を身に着け、長い黒髪をサラサラとなびかせながら、奇妙なポーズで近づいてくるとされる。\n\n深夜の道路脇で、看板の前にアクロバティックなポーズで立ちつくしている姿を見たという話。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        searchKeywords: ["都市伝説"],
        story: false
    ),
    
    Ayakasi(
        name: "神虫",
        documentId: "sintyu",
        imageName: "https://i.imgur.com/flpwgn1.png",
        description: "巨大な虫のような姿で描かれる怪物。節くれだった体と多数の脚、翼や触角を持ち、うごめくだけで禍々しい気配を放つという。",
        categories: ["すべて"],
        relatedCategory: nil,
        story: false
    ),
    Ayakasi(
        name: "ぬりかべ",
        documentId: "nurikabe",
        imageName: "https://i.imgur.com/k10aRdC.jpeg",
        description: "前進を阻む“壁”として感じられ、押しても避けても進めない。低い位置を叩くと消える、角を探すと抜けられるなどの対処譚が伝わる。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "傘小僧",
        documentId: "kasakozou",
        imageName: "https://i.imgur.com/Q5Y4U7J.png",
        imageSource: "パブリックドメイン",
        description: "一本足で飛び跳ねる、古い唐傘の妖怪。目玉と長い舌を持ち、雨の夜に出現すると言われる。人々を驚かせることを好むが、悪さはしないとされる。",
        categories: ["詳細不明","すべて"],
        relatedCategory: "詳細不明",
        searchKeywords: ["かさこぞう", "傘"],
        story: false
    )    ,
    Ayakasi(
        name: "牛鬼",
        documentId: "usioni",
        imageName: "https://imgur.com/hcnRbtx.jpeg",
        imageSource: "パブリックドメイン",
        description: "頭が牛で首から下は蜘蛛のような胴体、あるいはその逆の場合もある。人を襲うとされ、牛鬼が出現する前に、濡れ女が赤ん坊を抱かせようとしてくる。\n島根県で牛鬼の伝承が多い。男が釣りから帰ろうとしたとき、濡女が現れて赤子を渡すと消えてしまった。\n赤子を離そうとしても、石のようになって手から離れず、その間に牛鬼があらわれ襲いかかろうとするが、なんとか逃げ切って助かったという伝承がある。\n",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        searchKeywords: ["うしおに", "ウシオニ", "牛鬼", "濡れ女", "ぬれおんな", "牛", "うし", "蜘蛛", "くも", "島根", "しまね", "香川", "かがわ", "香川県", "根香寺", "ねごろじ", "水の怪", "海", "うみ", "ゲゲゲの鬼太郎"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "根香寺",
                coordinate: CLLocationCoordinate2D(latitude: 34.34323013625954, longitude: 133.96153552883618),
                description: "香川県の根香寺に伝わる牛鬼伝説。弓名人・山田蔵人高清が退治した牛鬼の角が今も寺に保存されている。牛鬼の絵は魔よけのお守りとして親しまれている。",
                yokaiIds: ["usioni"],
                prefecture: "香川県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    
    Ayakasi(
        name: "件",
        documentId: "kudan",
        imageName: "https://i.imgur.com/ZWININ4.jpeg",
        description: "件（くだん）は、牛の体に人の顔を持ち、牛からうまれる。\n地域によって、下は牛以外にも馬・ヘビ・魚などの生き物であると伝えられる。\n件（くだん）は、牛からうまれたあとに、その年の吉報あるいは災いを予言し、数日ほどで死ぬと伝えられ、その予言は決して外れないと言われた。\n具体的な逸話として、昔、牛からうまれた後に、「これから大変な世の中になるから、ヒエやアワなどの食料を蓄えるように」と告げ数日で死んだ。まもなくして、戦争が始まり、予言を告げられたものは食べ物に困らなかったという。\n ",
        categories: ["山の怪","すべて"],
        relatedCategory: "山の怪",
        searchKeywords: ["くだん", "人面牛", "予言"],
        story: false
    ),
    
    Ayakasi(
        name: "ぬらりひょん",
        documentId: "nurarihyon",
        imageName: "https://i.imgur.com/qkhjzxU.jpeg",
        description: "瓢箪のように長くつるりとした頭の老人。夜ふけに他人の家に上がり込み、茶を飲んだり家人を従わせたりするという。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        searchKeywords: ["ぬらりひょん"],
        story: false
    ),
    
    Ayakasi(
        name: "ろくろ首",
        documentId: "rokurokubi",
        imageName: "https://i.imgur.com/Z3P2J1E.png",
        imageSource: "パブリックドメイン",
        description: "昼は普通の人の姿で暮らし、夜に首だけが伸びて彷徨うとされる。自覚のない型・自覚して人を脅かす型の両方が伝わる。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["ろくろくび", "轆轤首"],
        story: false
    ),
    
    Ayakasi(
        name: "小豆洗い",
        documentId: "azukiarai",
        imageName: "https://imgur.com/xkEzUFq.jpeg",
        imageSource: "パブリックドメイン",
        description: "小豆洗い（あずきあらい）は川で小豆を洗う妖怪で、小豆とぎ（あずきとぎ）、小豆あらいど（あずきあらいど）など、様々な呼び名で全国的に分布している。\n小豆洗いは、川のほとりでシャキシャキと小豆をとぐ音が聞こえ、音をする方にいってもその姿はないといったものや、「小豆洗おか、人取って喰おか」など歌いながら小豆を洗うタイプもいる。",
        categories: ["音の怪","水の怪","すべて"],
        relatedCategory: "音の怪",
        searchKeywords: ["あずきあらい", "小豆とぎ", "あずきとぎ"],
        story: false
    ),
    Ayakasi(
        name: "影女",
        documentId: "kageonna",
        imageName: "https://i.imgur.com/qOqREju.png",
        description: "物の怪のいる家で、月影に照らされた女の姿の影が家の障子に映るものとされる",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        story: false
    ),
  
    Ayakasi(
        name: "猫又",
        documentId: "nekomata",
        imageName: "https://i.imgur.com/bjGICgl.png",
        imageSource: "パブリックドメイン",
        description: "長命の猫が尾を二つに分け、着物をまとって踊ったり三味線を弾いたりする。人に化けて家に入り込むこともある。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["ねこまた", "化け猫"],
        story: false
    ),
    
    Ayakasi(
        name: "狐",
        documentId: "kitsune",
        imageName: "https://i.imgur.com/IsPIXy5.jpeg",
        description: "人間や僧・美女などに化け、幻術や『狐火』で人を惑わす。九尾に至るほど霊力が高いとされる。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["きつね", "九尾", "狐火"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "殺生石",
                coordinate: CLLocationCoordinate2D(latitude: 37.10157952451793, longitude: 139.99920461905108),
                description: "九尾の狐伝説で言い伝えられる屈指のパワースポットで、殺生石は2022年3月に2つに割れ、話題を呼んでいるスポット。",
                yokaiIds: ["kitsune"],
                prefecture: "栃木県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "二口女",
        documentId: "futakuchionna",
        imageName: "https://i.imgur.com/esKjxgn.png",
        imageSource: "パブリックドメイン",
        description: "少食を装うが、もう一つの口で主に食べ物を摂取する。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        story: false
    ),
    Ayakasi(
        name: "百目鬼",
        documentId: "doumeki",
        imageName: "https://i.imgur.com/lIYjeST.png",
        description: "百目鬼(どうめき)とは腕や体に無数の目を持つ怪物、宇都宮では藤原秀郷によって退治されたという伝承がある。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "おおむかで",
        documentId: "oomukade",
        imageName: "https://i.imgur.com/pCB7BHG.png",
        description: "巨大なむかでの妖怪で、藤原秀郷が瀬田の唐橋で横たわっている大蛇に頼まれて、おおむかでを退治した",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["藤原秀郷","滋賀","瀬田の唐橋"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "瀬田の唐橋",
                coordinate: CLLocationCoordinate2D(latitude: 34.97314401171696, longitude: 135.90665321349147),
                description: "藤原秀郷が大蛇の頼みを受けて、巨大なむかでを退治したとされる伝説の橋。日本三名橋の一つ。",
                yokaiIds: ["oomukade"],
                prefecture: "滋賀県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),

    Ayakasi(
        name: "うわん",
        documentId: "uwan",
        imageName: "https://i.imgur.com/VYr7nhI.jpeg",
        description: "画図百鬼夜行や百怪図巻などに描かれた妖怪。お歯黒で、3本指の先には鋭い爪がついている。名前の通り、うわんと大きな声で人を驚かす。\n江戸時代、青森県の夫婦が古い屋敷に引っ越したその夜、「うわん」という大声が響いて一睡できなかった。\n近所の老人から「古い屋敷にはうわんという怪物が住んでいる」と聞いた。",
        categories: ["音の怪","すべて"],
        relatedCategory: "音の怪",
        story: false
    ),
    Ayakasi(
        name: "雪女",
        documentId: "yukionna",
        imageName: "https://i.imgur.com/5J4RYLD.png",
        description: "白い着物に長い黒髪、透き通るような肌。地に足跡を残さず、静かに漂うように現れるとされる。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        searchKeywords: ["ゆきおんな", "雪んば"],
        story: true,
        relatedSpots: [
            YokaiSpot(
                spotName: "雪おんな縁の地",
                coordinate: CLLocationCoordinate2D(latitude: 35.784586762798774, longitude: 139.26487723727587),
                description: "小泉八雲の小説『雪女』の舞台が、青梅にあった調布村であると類推されることから、2002年(平成14)に調布橋のたもとに碑が建てられた",
                yokaiIds: ["yukionna"],
                prefecture: "東京都",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "テケテケ",
        documentId: "teketeke",
        imageName: "https://i.imgur.com/RN94Yrq.jpeg",
        description: "上半身だけで地面を這いながら、“テケテケ”という音を立てて高速で迫る。見つかると逃げ切れないと言われ、出会った者に危害を加えるとされる。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        searchKeywords: ["都市伝説", "テケテケ"],
        story: false
    ),
    Ayakasi(
        name: "人面犬",
        documentId: "jinmenken",
        imageName: "https://i.imgur.com/uNrALt5.png",
        imageSource: "パブリックドメイン",
        description: "犬の体に人間の顔をついた奇妙な姿。“ワンワン”としゃべる、バイクに乗っている、夜道を歩いているなどバリエーションは豊富。見た目は気味が悪いが、実害は少ないとも言われる。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        story: false
    ),
  
    Ayakasi(
        name: "一つ目小僧",
        documentId: "hitotsumekozou",
        imageName: "https://i.imgur.com/dYXMVfh.png",
        imageSource: "パブリックドメイン",
        description: "目が一つしかない小僧の妖怪\n12月8日の晩になると人の目には見えない一つ目小僧が、戸締りされていない家をさがして入ってくるといわれてた。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["神奈川", "一つ目小僧"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "一つ目小僧地蔵",
                coordinate: CLLocationCoordinate2D(latitude: 35.482592556121666, longitude: 139.42085641534467),
                description: "昭和7年、単眼の頭蓋骨が発見され、供養のためにお地蔵様が祀られている。",
                yokaiIds: ["hitotsumekozou"],
                prefecture: "神奈川県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "トイレの花子さん",
        documentId: "toirenohanakosan",
        imageName: "https://i.imgur.com/nWT8xfl.jpeg",
        description: "赤いジャンパースカートに白いシャツ、おかっぱ頭の小学生の女の子。ランドセルを背負っていることも多い。女子トイレの3番目の個室から現れるとされ、呼びかけると返事をしたり、いたずら好きな一面も。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        searchKeywords: ["学校の怪談", "都市伝説","トイレ"],
        story: false
    ),
    Ayakasi(
        name: "のっぺらぼう",
        documentId: "nopperabou",
        imageName: "https://i.imgur.com/Yx7yjYf.png",
        imageSource: "パブリックドメイン",
        description: "ふつうの人型であるが、顔には目,鼻,耳,口がない妖怪\nおいてけ堀で釣った魚を持って帰ろうとすると、のっぺらぼうが現れ、逃げた先でも遭遇する。\nおいてけ堀の「おいてけ〜」という声の主は、河童とも言われており、おいてけ掘の舞台は、現在の錦糸町周辺とされる。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        searchKeywords: ["おいてけ", "顔"],
        story: true
    ),
    Ayakasi(
        name: "清姫",
        documentId: "kiyohime",
        imageName: "https://i.imgur.com/uCtfi1y.png",
        description: "紀伊国の娘・清姫は安珍に恋い焦がれ、やがて蛇となって追い詰め、道成寺の鐘に隠れた安珍を炎で焼き滅ぼしたと語られる。人の情念が怪へと変ずる典型。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["蛇", "和歌山","安珍","あんちんきよひめ"],
        story: true,
        relatedSpots: [
            YokaiSpot(
                spotName: "道成寺",
                coordinate: CLLocationCoordinate2D(latitude: 33.914798277659315, longitude: 135.17422150000002),
                description: "安珍清姫の伝説で知られる天台宗の古刹。清姫が蛇となって安珍を追い詰め、鐘の中で焼き殺したという物語の舞台。",
                yokaiIds: ["kiyohime"],
                prefecture: "和歌山県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "鵺",
        documentId: "nue",
        imageName: "https://i.imgur.com/togTHLQ.png",
        imageSource: "パブリックドメイン",
        description: "鵺(ぬえ)とは頭が猿で胴が狸、手足は虎で尾は蛇の姿で、鵺の鳴き声は、夜中に不穏な声で鳴くトラツグミに似ているとされる。都を騒がす鵺を退治するように命じられた源頼政が、夜に矢で射ったところ怪しいものが落ちた。\n火を灯してそれを見ると、頭は猿、体は狸、尾は蛇、手足は虎の姿をした妖怪がなくなっていたという話があり、その射った矢を洗ったのが鵺池とされる。\nそして、その死がいを丸木舟にのせて川に流したところ、最終的に芦屋に漂着した。\n祟りを恐れた村人たちは立派な墓をつくり、これが今日までに残る鵺塚である。",
        categories: ["音の怪","すべて"],
        relatedCategory: "音の怪",
        searchKeywords: ["ぬえ", "トラツグミ", "源頼政","西脇","兵庫"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "長明寺",
                coordinate: CLLocationCoordinate2D(latitude: 34.96435197050908, longitude: 134.9776680865085),
                description: "兵庫県西脇市にある長明寺。源頼政による鵺退治像があり、平家物語の伝説を今に伝える。",
                yokaiIds: ["nue"],
                prefecture: "兵庫県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
   
    Ayakasi(
        name: "濡れ女",
        documentId: "nureonna",
        imageName: "https://i.imgur.com/Von1CEd.jpeg",
        description: "長い黒髪と濡れた和服、青白い肌を持つ。哀しげな表情で現れ、川や沼のほとり、橋の上を歩く姿が多い。恐怖の象徴でありつつ、水難事故への警告とされることもある。",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        story: false
    ),
    Ayakasi(
        name: "すなかけばばあ",
        documentId: "sunakakebabaa",
        imageName: "https://i.imgur.com/AXzMxMo.jpeg",
        description: "背の曲がった老婆の姿で現れ、手にした杓や袋から砂を浴びせて人を惑わせるとされる。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    Ayakasi(
        name: "鬼",
        documentId: "oni",
        imageName: "https://i.imgur.com/XbUp4lJ.png",
        imageSource: "パブリックドメイン",
        description: "赤や青の肌、虎皮の褌、手には金棒。残虐な怪として語られる一方、悪を懲らす存在や守護の側面が描かれることもある。",
        categories: ["山の怪","すべて"],
        relatedCategory: "山の怪",
        searchKeywords: ["おに", "オニ", "鬼", "赤鬼", "あかおに", "青鬼", "あおおに", "岩手", "いわて", "岩手県", "盛岡", "もりおか", "三ツ石神社", "みついしじんじゃ", "さんさ踊り", "金棒", "虎皮", "節分", "山の怪", "桃太郎"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "三ツ石神社",
                coordinate: CLLocationCoordinate2D(latitude: 39.70900790250411, longitude: 141.154569276687),
                description: "岩手県盛岡市にある神社。鬼が三つの巨石に手形を押して二度と現れないと約束した伝説が残り、「岩手」の地名の由来となった。盛岡三大祭りの一つ「さんさ踊り」の起源でもある。",
                yokaiIds: ["oni"],
                prefecture: "岩手県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "河童",
        documentId: "kappa",
        imageName: "https://i.imgur.com/Pkgy79t.png",
        imageSource: "パブリックドメイン",
        description:"カッパは、日本全国の川・池・沼・海などの水界に棲み、陸上も歩行する。カッパという呼称が一般的であるが、ガワタロ、メドチなど場所によっていろいろな呼び方がある。\nカッパは、子供を溺死させたり、馬を川へ引きずり込んだり、田畑を荒らしたりするといった恐ろしい一面をもつ一方で、田植え、田の草取りの手伝いをしたり、命を助けてもらったお礼として人間に薬の製法を教えたりもするといったエピソードもある",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        searchKeywords: ["かっぱ", "カッパ", "河童", "ガワタロ", "メドチ", "水虎", "すいこ", "水の怪", "川", "かわ", "皿", "さら", "キュウリ", "きゅうり", "胡瓜", "相撲", "すもう", "尻子玉", "遠野物語", "岩手", "ゲゲゲの鬼太郎", "妖怪ウォッチ"],
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "錦糸堀公園",
                coordinate: CLLocationCoordinate2D(latitude: 35.694625020814044, longitude: 139.81623236132535),
                description: "おいてけ堀の由来となった場所であり河童の像があります",
                yokaiIds: ["kappa"],
                prefecture: "東京都",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "がしゃどくろ",
        documentId: "gashadokuro",
        imageName: "https://imgur.com/T7k09o9.jpeg",
        imageSource: "パブリックドメイン",
        description: "家屋をも見下ろすほどの巨体の骸骨で、闇夜に現れて旅人を襲うとされる。顎を鳴らす音や不気味な気配とともに近づき、油断した者の首を噛みちぎるという。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
       
        story: false
    ),
    Ayakasi(
        name: "いったんもめん",
        documentId: "ittanmomen",
        imageName: "https://i.imgur.com/GTQ0w2t.png",
        imageSource: "パブリックドメイン",
        description: "白い反物が生き物のようにたなびき、風に乗って飛ぶ。人の顔に巻きついたり、肩にまとわりついたりする挙動が語られる。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false,
        relatedSpots: [
            YokaiSpot(
                spotName: "轟の滝",
                coordinate: CLLocationCoordinate2D(latitude: 31.3464863174227, longitude: 131.00797480714246),
                description: "この滝や近くの権現山は一旦木綿伝承の地とされている。",
                yokaiIds: ["ittanmomen"],
                prefecture: "鹿児島県",
                imageURL: nil,
                spotType: .yokaiRelated
            )
        ]
    ),
    Ayakasi(
        name: "てんぐ",
        documentId: "tengu",
        imageName: "https://imgur.com/szimXYf.jpeg",
        imageSource: "パブリックドメイン",
        description: "長い鼻の大天狗、鳥の嘴を思わせる烏天狗などの相。山風を操り、剣術・幻術に長けるとされる。",
        categories: ["山の怪","すべて"],
        relatedCategory: "山の怪",
        searchKeywords: ["天狗", "烏天狗", "カラステング"],
        story: false
    ),
    
    Ayakasi(
        name: "うみぼうず",
        documentId: "umibouzu",
        imageName: "https://i.imgur.com/06WVJKo.png",
        imageSource: "パブリックドメイン",
        description: "海面から巨大な黒い僧形の影が現れ、船を揺らし、油を要求するなどの話型がある。桶を差し出し機先を制する対処譚も有名。",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        story: false
    ),
    Ayakasi(
        name: "口裂け女",
        documentId: "kuchisakenna",
        imageName: "https://i.imgur.com/2Y4Vghp.jpeg",
        description: "長い黒髪とコート姿、顔の下半分をマスクや布で隠していることが多い。正体は不明だが、マスクを外すと口が耳まで大きく裂けている。怖がらせる存在として語られるが、対処法や撃退エピソードも有名。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        story: false
    ),
    
    Ayakasi(
        name: "わにゅうどう",
        documentId: "wanyuudou",
        imageName: "https://i.imgur.com/QLY9RUK.png",
        imageSource: "パブリックドメイン",
        description: "燃える大車輪に苦悶の表情の頭部が付いた姿で夜道を転がる。見る者の魂を奪うとも子を攫うともいう。",
        categories: ["道の怪","すべて"],
        relatedCategory: "道の怪",
        story: false
    ),
    
    Ayakasi(
        name: "玉梓",
        documentId: "tamasusa",
        imageName: "https://i.imgur.com/awxxXQe.jpeg",
        description: "神余光弘の愛妾から山下定包の妻となった美女。里見義実に捕らえられ斬首される際、呪詛を残し怨霊化して里見家を祟る。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        story: false
    ),
    
    Ayakasi(
        name: "やまんば",
        documentId: "yamanba",
        imageName: "https://i.imgur.com/eqzWV4L.png",
        imageSource: "パブリックドメイン",
        description: "乱れ髪に異様な力を持つ山姥。旅人を惑わし喰らう話の一方、子を授ける・助けるなど多面的な像を持つ。",
        categories: ["山の怪","すべて"],
        relatedCategory: "山の怪",
        searchKeywords: ["やま", "ばばあ"],
        story: true
    ),
    
    Ayakasi(
        name: "座敷童",
        documentId: "zashikiwarashi",
        imageName: "https://i.imgur.com/4M0QBCe.png",
        description: "童子姿で家の中を走り回る気配を残す。姿が見えなくなると家運が傾くという俗信が広い。",
        categories: ["家の怪","すべて"],
        relatedCategory: "家の怪",
        story: true
    ),
    Ayakasi(
        name: "かまいたち",
        documentId: "kamaitachi",
        imageName: "https://i.imgur.com/DA4BdY7.jpeg",
        description: "かまいたちは、外見はイタチに似ると考えられる一方、実際には人間の目には見えないともされる。また、痛みを感じないうちに深い傷を負わせるが、そのわりには出血はしない現象を指す。\n岐阜県の飛騨地方などでは、かまいたちは三人の神様と考えられる。\n最初の神様がぶつかって人を転ばせ、二番目の神様が切りつけ、三番目の神様が薬をつけて治す。よって、鎌で切ったような傷の形をしていながら、出血や痛みがないとされる。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["かまいたち"],
        story: false
    ),
    Ayakasi(
        name: "こなき爺",
        documentId: "konakijiji",
        imageName: "https://i.imgur.com/HCbgWxu.png",
        description: "赤子の泣き声で人を誘い、抱き上げると途端に重さが増して身動きを取れなくさせる山の怪。",
        categories: ["山の怪","すべて"],
        relatedCategory: "山の怪",
        searchKeywords: ["ゲゲゲの鬼太郎", "こなきじじい","子泣き","こなき爺"],
        story: false
    ),
    Ayakasi(
        name: "船幽霊",
        documentId: "funayurei",
        imageName: "https://i.imgur.com/3J2qyCn.png",
        imageSource: "パブリックドメイン",
        description: "霧の夜に現れ、桶や柄杓を求めて船に取りつく海の怪。渡すと水を汲み入れて沈めるとされる。",
        categories: ["水の怪","すべて"],
        relatedCategory: "水の怪",
        searchKeywords: ["船", "ひしゃく","船幽霊","海","ふなゆうれい"],
        story: false
    ),
    Ayakasi(
        name: "ひきこさん",
        documentId: "hikikosan",
        imageName: "https://i.imgur.com/CtKYJvM.png",
        description: "雨の日に白いぼろ着で現れ、目撃した子どもを引きずると噂される女の怪異。",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        searchKeywords: ["都市伝説", "ひきこさん"],
        story: false
    ),
    Ayakasi(
        name: "吉原千恵子",
        documentId: "yoshiwarachieko",
        imageName: "https://i.imgur.com/Gzt7TEP.png",
        description: "2000年代初頭にチェーンメールで広まった",
        categories: ["都市伝説","すべて"],
        relatedCategory: "都市伝説",
        searchKeywords: ["吉原千恵子", "チェーンメール","都市伝説"],
        story: false
    ),
    Ayakasi(
        name: "犬神",
        documentId: "inugami",
        imageName: "https://i.imgur.com/4ItCkkf.png",
        imageSource: "パブリックドメイン",
        description: "西日本に広く伝わる犬霊の憑き物。特に四国を中心に根強く信仰され、人や家に憑いて福や禍をもたらすとされる。地域によってインガメ、イリガミなどとも呼ばれる。",
        categories: ["動物の怪","すべて"],
        relatedCategory: "動物の怪",
        searchKeywords: ["いぬがみ", "犬神", "インガメ", "イリガミ", "狗神", "憑き物", "つきもの", "四国", "西日本", "大分", "島根", "高知", "熊本", "宮崎"],
        story: false
    ),
    Ayakasi(
        name: "鬼女",
        documentId: "kijo",
        imageName: "https://i.imgur.com/8QkhNl3.png",
        imageSource: "パブリックドメイン",
        description: "人間の女性が怨念や宿業によって鬼と化したもの。若い女性を鬼女、老婆姿を鬼婆と呼ぶ。紅葉伝説、鈴鹿御前、安達ヶ原の鬼婆（黒塚）などが有名。転じて、心の酷い女性や怒った女性を指すこともある。",
        categories: ["詳細不明","すべて"],
        relatedCategory: "詳細不明",
        searchKeywords: ["きじょ", "鬼女", "きばば", "鬼婆", "紅葉", "もみじ", "紅葉伝説", "鈴鹿御前", "すずかごぜん", "安達ヶ原", "あだちがはら", "黒塚", "くろづか", "戸隠", "とがくし", "鬼無里", "きなさ", "長野", "福島", "土佐", "高知"],
        story: false
    ),
    Ayakasi(
        name: "胴面",
        documentId: "dounotsura",
        imageName: "https://i.imgur.com/MlAWmAA.png",
        imageSource: "パブリックドメイン",
        description: "首から上がなく、代わりに胴体に顔がある妖怪。尾田郷澄『百鬼夜行絵巻』に描かれているが、詳細は不明。",
        categories: ["詳細不明","すべて"],
        relatedCategory: "詳細不明",
        searchKeywords: ["どうのつら", "胴面", "どうめん", "百鬼夜行絵巻", "ひゃっきやぎょうえまき", "あかはだか", "赤裸", "刑天", "けいてん", "尾田郷澄", "おだごうちょう", "山海経", "せんがいきょう"],
        story: false
    ),
    Ayakasi(
        name: "飛縁魔",
        documentId: "hinoennma",
        imageName: "https://i.imgur.com/YypCD91.png",
        imageSource: "パブリックドメイン",
        description: "外見は美しい女性だが、男の心を迷わせて身を滅ぼす妖怪。江戸時代の『絵本百物語』に登場。女犯を戒めるために創作されたとされる。",
        categories: ["人の怪","すべて"],
        relatedCategory: "人の怪",
        searchKeywords: ["ひのえんま", "飛縁魔", "えんしょうじょ", "縁障女", "絵本百物語", "えほんひゃくものがたり", "丙午", "ひのえうま", "八百屋お七", "やおやおしち", "妖婦", "ようふ", "女の怪"],
        story: false
    )
]

