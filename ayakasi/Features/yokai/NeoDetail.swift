import SwiftUI
import Photos
import Kingfisher

struct NeoDetail: View {
    let yokai : Ayakasi
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showFullScreenImage = false
    @State private var showAlert : Bool = false
    @State private var alertMessage : String = ""
    @State private var showStoryView = false
    @EnvironmentObject var colorVM : ColorViewModel
    @EnvironmentObject var voteService : VoteService
    @EnvironmentObject var authVM : AuthViewModel
    
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
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack{
                    ZStack{
                        Group{
                            if let url = URL(string: yokai.imageName) , url.scheme?.hasPrefix("http") == true{
                                KFImage(url)
                                    .placeholder {
                                        Image("loading")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                    .cacheOriginalImage()
                                    .resizable()
                                    .scaledToFill()
                            }else{
                                Image(yokai.imageName)
                                    .resizable()
                                    .scaledToFill()
                            }
                            
                        }
                        .onTapGesture {
                            showFullScreenImage = true
                        }
                        .fullScreenCover(isPresented: $showFullScreenImage){
                            FullScreenImage(imageName: yokai.imageName)
                        }
                        
                        
                        HStack{
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
                        .padding(.horizontal,20)
                        .padding(.top,48)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        
                        
                        Text(yokai.name)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)  // ハートボタンと同じ高さに
                            .padding(.leading, 32)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        
                    }
                    
                    // 2タブ
                    Group{
                        //                        HStack{
                        //                            Text("説明")
                        //                                .fontWeight(.bold)
                        //                                .padding(.vertical,16)
                        //                                .foregroundStyle(selectedTab == 0 ? colorVM.currentColor : .black.opacity(0.3))
                        //                                .frame(width: screenWidth * 0.45)
                        //                                .overlay(alignment: .bottom) {
                        //                                    Rectangle()
                        //                                        .frame(height: 2)
                        //                                        .frame(width: screenWidth * 0.45)
                        //                                        .foregroundStyle(selectedTab == 0 ? colorVM.currentColor : .black.opacity(0.3))
                        //                                }
                        //                                .onTapGesture {
                        //                                    selectedTab = 0
                        //                                }
                        //
                        //                            Text("その他")
                        //                                .fontWeight(.bold)
                        //                                .padding(.vertical,16)
                        //                                .foregroundStyle(selectedTab == 1 ? colorVM.currentColor : .black.opacity(0.3))
                        //                                .frame(width: screenWidth * 0.45)
                        //                                .overlay(alignment: .bottom) {
                        //                                    Rectangle()
                        //                                        .frame(height: 2)
                        //                                        .frame(width: screenWidth * 0.45)
                        //                                        .foregroundStyle(selectedTab == 1 ? colorVM.currentColor : .black.opacity(0.4))
                        //                                }
                        //                                .onTapGesture {
                        //                                    selectedTab = 1
                        //                                }
                        //                        }
                        //                        .padding(.vertical,8)
                        //                        .padding(.horizontal,8)
                        
                        //                        VStack{
                        
                        VStack{
                            HStack{
                                Image("description")
                                    .renderingMode(.template)
                                Text("説明")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(.horizontal,24)
                            .padding(.top,20)
                            .padding(.bottom,12)
                            
                            
                            Text(yokai.description)
                                .fontWeight(.bold)
                                .padding(.vertical,6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal,24)
                            
                            if let episodes = yokai.episodes {
                                VStack{
                                    HStack{
                                        Image("episode")
                                            .renderingMode(.template)
                                        Text("エピソード")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }
                                    .padding(.top,16)
                                    
                                    Text(episodes)
                                        .fontWeight(.bold)
                                        .padding(.vertical,4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                }
                                .padding(.horizontal,24)
                                .padding(.bottom,16)
                            }
                            
                            if let btw = yokai.btw {
                                VStack{
                                    ByTheWay(btw: btw)
                                }
                            }
                            
                            if yokai.sotry {
                                Button {
                                    showStoryView = true
                                } label: {
                                    Text("物語を読む")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 8).fill(colorVM.currentColor))
                                }
                                .padding(.horizontal, 24)
                            }
                            
                        }
                        
                        
                        //                        }
                        
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
                                Image("description")
                                    .renderingMode(.template)
                                Text("関連のある妖怪")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(.horizontal,24)
                            .padding(.top,24)
                            .padding(.bottom,12)
                            
                            ScrollView(.horizontal,showsIndicators: false){
                                
                                HStack(spacing: 16){
                                    ForEach(relatedYokais.prefix(7)){ ayakasi in
                                        PickupCard(ayakasi: ayakasi)
                                    }
                                }
                                .padding(.horizontal,20)
                                .padding(.vertical,24)
                            }
                        }
                        
                    }
                    
                    
                }
                
            }
            // フローティング投票ボタン
            .overlay(alignment: .bottomTrailing) {
                
                
                Button {
                    Task {
                        do {
                            try await voteService.vote(aykasiId: yokai.documentId)
                        } catch let error as VoteError {
                            // VoteErrorの場合、日本語メッセージを表示
                            alertMessage = error.localizedDescription
                            showAlert = true
                        } catch {
                            // その他のエラー
                            print("投票エラー詳細: \(error)")  // デバッグ用
                            
                            alertMessage = "投票中にエラーが発生しました"
                            showAlert = true
                        }
                    }
                    
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.white)
                            .font(.title2)
                        Text("\(voteService.voteCountCache[yokai.documentId] ?? 0)")
                            .foregroundStyle(.white)
                            .font(.caption)
                            .bold()
                    }
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.red.opacity(0.8)))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom,16)
                
                
                
                
            }
            
        }
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    // 横方向の移動が縦方向より大きい場合のみ反応
                    if abs(value.translation.width) > abs(value.translation.height) && abs(value.translation.width) > 50 {
                        if value.translation.width > 0 {
                            // 右スワイプ = 前のタブへ
                            selectedTab = 0
                        } else {
                            // 左スワイプ = 次のタブへ
                            selectedTab = 1
                        }
                    }
                }
        )
        .alert("", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .ignoresSafeArea(edges: .top) // ノッチやステータスバーを無視
        .background(.ivory)
        .fullScreenCover(isPresented: $showStoryView) {
            StoryView(yokaiName: yokai.name)
        }
        .safeAreaInset(edge: .bottom){
            BottomActionBar(
                yokai: yokai,
                screenWidth: screenWidth,
                requestAndSaveImage: requestAndSaveImage
            )
        }
        
        
    }
}
