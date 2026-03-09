import SwiftUI
import Photos
import Kingfisher
import FirebaseFirestore
import MapKit

struct CommentListView: View {
    let comments: [[String: Any]]
    @EnvironmentObject var commentService: CommentService
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedCommentId: String = ""
    @State private var reportTarget: ReportTarget?
    
    var body: some View {
        if comments.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "bubble.left")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                Text("まだコメントがありません")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            ForEach(Array(comments.enumerated()), id: \.offset) { index, comment in
                VStack{
                    HStack{
                        Text("\(index+1).")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        if let timestamp = comment["createdAt"] as? Timestamp {
                            Text(DateFormatter.shortDateTime.string(from: timestamp.dateValue()))
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("時刻を取得できませんでした")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        HStack{
                            Spacer()
                            if authVM.user != nil {
                                Image(systemName: "ellipsis")
                                    .font(.title3)
                                    .onTapGesture {
                                        guard let docId = comment["documentId"] as? String, !docId.isEmpty else {
                                            print("❗️ documentId is missing; not opening report sheet")
                                            return
                                        }
                                        
                                        selectedCommentId = docId
                                        reportTarget = ReportTarget(id: docId)
                                        
                                    }
                            }
                        }
                    }
                    .padding(.bottom,4)
                    HStack{
                        Text(comment["content"] as? String ?? "コメントを取得できませんでした")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
                .padding(.horizontal,24)
                .padding(.bottom,2)
                
                if index < comments.count - 1 {
                    Divider()
                        .padding(.horizontal,24)
                        .padding(.bottom,12)
                }
            }
            .padding(.top,12)
            .sheet(item: $reportTarget) { target in
                if let comment = comments.first(where: { ($0["documentId"] as? String) == target.id }),
                   let userId = comment["userId"] as? String {
                    ReportUI(commentId: target.id, userId: userId)
                        .presentationDetents([.fraction(0.25)])
                        .presentationBackground(.regularMaterial)
                }
            }
        }
    }
}

struct NeoDetail: View {
    let yokai : Ayakasi
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showFullScreenImage = false
    @State private var showAlert : Bool = false
    @State private var alertMessage : String = ""
    @State private var showStoryView = false
    @State private var isCommentUI = false
    @State private var voteSuccess = false
    @EnvironmentObject var voteService : VoteService
    @EnvironmentObject var authVM : AuthViewModel
    @EnvironmentObject var commentVM : CommentService
    @EnvironmentObject var favoriteService : FavoriteService
    
    private func requestAndSaveImage(imageName: String){
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:          // すでに許可あり → 保存
            saveImage(imageName: imageName)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async{
                    if status == .authorized || status == .limited {
                        saveImage(imageName: imageName)
                    }else{
                        alertMessage = "フォトライブラリアクセス許可が得られませんでした"
                        showAlert = true
                    }
                }
            }
        case .denied:
            alertMessage = "写真アクセスが拒否されています。設定アプリで許可してください"
            showAlert = true
        case .restricted:
            alertMessage = "写真アクセスが制限されています"
            showAlert = true
        @unknown default:
            alertMessage = "写真アクセス状態が不明です"
            showAlert = true
            
        }
    }
    
    private func saveImage(imageName : String){
        // URLの場合とローカル画像の場合で処理を分ける
        if let url = URL(string: imageName), url.scheme?.hasPrefix("http") == true {
            // URLから画像を保存
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    UIImageWriteToSavedPhotosAlbum(value.image, nil, nil, nil)
                    DispatchQueue.main.async {
                        self.alertMessage = "保存しました"
                        self.showAlert = true
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.alertMessage = "画像の取得に失敗しました"
                        self.showAlert = true
                    }
                }
            }
        } else {
            // ローカル画像の場合
            guard let uiImage = UIImage(named: imageName) else {
                alertMessage = "画像が見つかりません"
                showAlert = true
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            alertMessage = "保存しました"
            showAlert = true
        }
    }
    
    private var imageView: some View {
        Group{
            if let url = URL(string: yokai.imageName), url.scheme?.hasPrefix("http") == true{
                KFImage(url)
                    .placeholder {
                        Image("loading")
                            .resizable()
                            .scaledToFill()
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
            } else {
                Image(yokai.imageName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .onTapGesture {
            showFullScreenImage = true
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImage(imageName: yokai.imageName, requestAndSaveImage: requestAndSaveImage)
        }
    }
    
    private var backButtonView: some View {
        HStack {
            Circle()
                .fill(Color.black.opacity(0.6))
                .frame(width: screenWidth * 0.1, height: screenWidth * 0.1)
                .overlay(
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.white)
                        .padding()
                )
                .onTapGesture {
                    dismiss()
                }
        }
        .padding(.horizontal, 20)
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var titleView: some View {
        Text(yokai.name)
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
            .font(.title)
            .fontWeight(.bold)
            .padding(.bottom, 20)
            .padding(.leading, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack{
                    ZStack{
                        imageView
                        backButtonView
                        titleView
                        
                    }
                    
                    // 2タブ
                    Group{
                        HStack{
                            Text("情報")
                                .fontWeight(.bold)
                                .padding(.vertical,16)
                                .foregroundStyle(selectedTab == 0 ? .black : .black.opacity(0.3))
                                .frame(width: screenWidth * 0.45)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 2)
                                        .frame(width: screenWidth * 0.45)
                                        .foregroundStyle(selectedTab == 0 ? .black : .black.opacity(0.3))
                                }
                                .onTapGesture {
                                    selectedTab = 0
                                }
                            
                            Text("コメント")
                                .fontWeight(.bold)
                                .padding(.vertical,16)
                                .foregroundStyle(selectedTab == 1 ? .black : .black.opacity(0.3))
                                .frame(width: screenWidth * 0.45)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 2)
                                        .frame(width: screenWidth * 0.45)
                                        .foregroundStyle(selectedTab == 1 ? .black : .black.opacity(0.3))
                                }
                                .onTapGesture {
                                    selectedTab = 1
                                }
                        }
                        .padding(.vertical,8)
                        .padding(.horizontal,8)
                        
                        if selectedTab == 0{
                            VStack{
                                
                                Text(yokai.description)
                                    .fontWeight(.bold)
                                    .padding(.vertical,12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal,24)
                                
  
                                // ゆかりの地セクション
                                if let relatedSpots = yokai.relatedSpots, !relatedSpots.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("ゆかりの地")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 16)
                                        
                                        // 複数スポット対応 - 横スクロール
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(relatedSpots) { spot in
                                                    VStack(spacing: 12) {
                                                        // 小さな地図プレビュー
                                                        Map(initialPosition: .region(
                                                            MKCoordinateRegion(
                                                                center: spot.coordinate,
                                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                                            )
                                                        )) {
                                                            Annotation(spot.spotName, coordinate: spot.coordinate) {
                                                                ZStack {
                                                                    Circle()
                                                                        .fill(Color.blue)
                                                                        .frame(width: 30, height: 30)
                                                                    Image(systemName: "sparkles")
                                                                        .foregroundColor(.white)
                                                                        .font(.system(size: 14))
                                                                }
                                                            }
                                                        }
                                                        .frame(height: 150)
                                                        .cornerRadius(12)
                                                        .allowsHitTesting(false)
                                                        
                                                        VStack(alignment: .leading, spacing: 8) {
                                                          
                                                            Text(spot.prefecture)
                                                                .font(.headline)
                                                                .foregroundColor(.gray)
                                                            
                                                            if let description = spot.description {
                                                                Text(description)
                                                                    .font(.caption)
                                                                    .foregroundColor(.gray)
                                                                    .padding(.top, 4)
                                                            }
                                                        }
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        
                                                        Button {
                                                            // Google Mapで開く
                                                            let urlString = "https://www.google.com/maps/search/?api=1&query=\(spot.coordinate.latitude),\(spot.coordinate.longitude)"
                                                            if let url = URL(string: urlString) {
                                                                UIApplication.shared.open(url)
                                                            }
                                                        } label: {
                                                            HStack {
                                                                Image(systemName: "map.fill")
                                                                Text("Google Mapで\(spot.spotName)を開く")
                                                                    .fontWeight(.medium)
                                                            }
                                                            .frame(maxWidth: .infinity)
                                                            .padding(.vertical, 12)
                                                            .background(Color.blue)
                                                            .foregroundColor(.white)
                                                            .cornerRadius(8)
                                                        }
                                                    }
                                                    .frame(width: screenWidth * 0.75)
                                                    .padding()
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color.white)
                                                    )
                                                }
                                            }
                                            .padding(.horizontal, 24)
                                        }
                                        .padding(.bottom, 12)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                }
                                
                                if yokai.story {
                                    Button {
                                        showStoryView = true
                                    } label: {
                                        Text("物語を読む")
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 8).fill(.black))
                                    }
                                    .padding(.horizontal, 24)
                                }
                                
                            }
                        } else{
                            CommentListView(comments: commentVM.yokaiComments)
                        }
                        
                        //関連妖怪
                        let relatedYokais = ayakasis.filter { ayakasi in
                            if let yokaiRelatedCategory = yokai.relatedCategory,
                               let ayakasiRelatedCategory = ayakasi.relatedCategory {
                                return yokaiRelatedCategory == ayakasiRelatedCategory && ayakasi.documentId != yokai.documentId
                            }
                            return false
                        }
                        
                        if !relatedYokais.isEmpty {
                            HStack{
                                Image("info")
                                    .renderingMode(.template)
                                Text("関連のある妖怪")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(.horizontal,24)
                            .padding(.top,28)
                            
                            ScrollView(.horizontal,showsIndicators: false){
                                HStack(spacing: 16){
                                    ForEach(relatedYokais.prefix(7)){ ayakasi in
                                        NavigationLink(destination: NeoDetail(yokai: ayakasi)) {
                                            NeoCardItem(item: ayakasi)
                                        }
                                        
                                    }
                                }
                                .padding(.horizontal,20)
                                .padding(.bottom,72)
                                .padding(.top,12)
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .alert("", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .ignoresSafeArea(edges: .top) // ノッチやステータスバーを無視
        .background(.ivory)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showStoryView) {
            StoryView(yokaiName: yokai.name)
        }
        .fullScreenCover(isPresented: $authVM.isShowLoginView) {
            LoginView()
        }
        .fullScreenCover(isPresented: $authVM.isShowRegisterView) {
            RegisterView()
        }
        .task {
            await commentVM.fetchYokaiComments(yokaiId: yokai.documentId)
            // 詳細画面を開いたら自動で既読にする
            if !favoriteService.isReadYokai(yokai.documentId) {
                favoriteService.toggleReadYokai(yokai.documentId)
            }
        }
        .sheet(isPresented: $isCommentUI) {
            CommentUI(isPresented: $isCommentUI, yokai: yokai)
                .presentationDetents([.fraction(0.35)])
                .presentationBackground(.regularMaterial)
        }
        .safeAreaInset(edge: .bottom){
            BottomActionBar(
                yokai: yokai,
                screenWidth: screenWidth,
                isCommentUI: $isCommentUI,
                voteSuccess: $voteSuccess,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        }
    }
}
