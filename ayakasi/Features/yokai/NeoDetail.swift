import SwiftUI
import StoreKit
import Photos
import Kingfisher
import os

struct CommentListView: View {
    let comments: [YokaiComment]
    let onChanged: () async -> Void

    var body: some View {
        if comments.isEmpty {
            VStack(spacing: 16) {
                Image("forum")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.appTextSecondary)
                
                Text("まだコメントがありません")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appTextSecondary)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(comments) { comment in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.appTextSecondary.opacity(0.5))
                        VStack(alignment: .leading, spacing: 4) {
                            if comment.isWithdrawn {
                                Text("退会したユーザー")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                            }
                            Text(comment.content)
                                .font(.body)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
                        }
                        Spacer(minLength: 0)
                        if comment.isMine {
                            Spacer().frame(width: 32)
                        } else {
                            CommentMenu(comment: comment, onDone: onChanged)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
}

struct NeoDetail: View {
    let yokai : Ayakasi
    var source: String = "unknown"
    let screenWidth = UIScreen.main.bounds.width
    @State private var showFullScreenImage = false
    @State private var showAlert : Bool = false
    @State private var alertMessage : String = ""
    @State private var showStoryView = false
    @State private var isCommentUI = false
    @State private var selectedRelatedYokai: Ayakasi? = nil
    @EnvironmentObject var authVM : AuthViewModel
    @EnvironmentObject var commentVM : CommentService
    @EnvironmentObject var favoriteService : FavoriteService
    @Environment(\.requestReview) private var requestReview
    
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
            if yokai.imageName == "NoImage" {
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.square")
                        .font(.system(size: 48))
                    Text("No Image")
                        .font(.subheadline)
                }
                .foregroundColor(.appTextSecondary)
                .frame(width: screenWidth, height: screenWidth * 0.75)
                .background(Color.gray.opacity(0.12))
            } else if let url = URL(string: yokai.imageName), url.scheme?.hasPrefix("http") == true{
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
            if yokai.imageName != "NoImage" {
                showFullScreenImage = true
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImage(imageName: yokai.imageName, requestAndSaveImage: requestAndSaveImage)
        }
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
    
    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        sectionHeader(title) { Image(systemName: systemImage) }
    }

    private func sectionHeader(_ title: String, @ViewBuilder icon: () -> some View) -> some View {
        HStack {
            icon()
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text("・\(item)")
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    // スポット画面(ログ)は仮UIなので、リリース版では今までどおりGoogleマップを開く
    @ViewBuilder
    private func spotCard(_ spot: YokaiSpot) -> some View {
        #if DEBUG
        NavigationLink {
            SpotDetailView(spot: spot)
        } label: {
            spotCardLabel(spot, action: "くわしく見る", systemImage: "chevron.right")
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            Analytics.trackSpotCardTapped(spotName: spot.spotName, prefecture: spot.prefecture, yokaiName: yokai.name)
        })
        #else
        Button {
            Analytics.trackSpotCardTapped(spotName: spot.spotName, prefecture: spot.prefecture, yokaiName: yokai.name)
            let urlString = "https://www.google.com/maps/search/?api=1&query=\(spot.coordinate.latitude),\(spot.coordinate.longitude)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } label: {
            spotCardLabel(spot, action: "地図で開く", systemImage: "arrow.up.right.square")
        }
        .buttonStyle(.plain)
        #endif
    }

    private func spotCardLabel(_ spot: YokaiSpot, action: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // 地図にしないのは、小さな正方形の地図では場所が読み取れないため(場所は「地図で開く」で見る)
            YokaiThumbnail(yokai: yokaiById(spot.yokaiIds.first ?? "") ?? yokai, size: 96)

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.spotName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(spot.prefecture)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                if let description = spot.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 2)
                }
                Label(action, systemImage: systemImage)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.appSecondary)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var body: some View {
        ZStack{
            ScrollView{
                VStack{
                    ZStack{
                        imageView
                        titleView
                    }
                    
                    if yokai.imageSource != nil || yokai.imageAuthor != nil || yokai.imageTitle != nil {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                if let imageSource = yokai.imageSource {
                                    Text(imageSource)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.appTextSecondary)
                                }
                                if let imageAuthor = yokai.imageAuthor, let imageTitle = yokai.imageTitle {
                                    Text("\(imageAuthor)　\(imageTitle)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.appTextSecondary)
                                } else if let imageAuthor = yokai.imageAuthor {
                                    Text(imageAuthor)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.appTextSecondary)
                                } else if let imageTitle = yokai.imageTitle {
                                    Text(imageTitle)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.appTextSecondary.opacity(0.1))
                            .cornerRadius(12)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }

                    
                    Group {
                        VStack{
                            let tags = yokai.categories.filter { $0 != "すべて" }
                            if !tags.isEmpty {
                                Text(tags.map { "#\($0)" }.joined(separator: "  "))
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 12)
                            }

                            sectionHeader("どんな妖怪？", systemImage: "book.closed")
                            // 太字にしないのは、説明を長くしたときに読みにくいため
                            Text(yokai.description)
                                .lineSpacing(6)
                                .padding(.top, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal,24)

                            if let appearances = yokai.appearances, !appearances.isEmpty {
                                sectionHeader("登場する作品", systemImage: "tv")
                                bulletList(appearances)
                            }

                            if let books = yokai.books, !books.isEmpty {
                                sectionHeader("もっと知れる本", systemImage: "books.vertical")
                                bulletList(books)
                            }

                            if let videoId = yokai.videoId {
                                NavigationLink(destination: WebView(url: URL(string: "https://www.youtube.com/watch?v=\(videoId)"))) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                        Text("YouTubeで見る")
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                            }

                            if let relatedSpots = yokai.relatedSpots, !relatedSpots.isEmpty {
                                sectionHeader("ゆかりの地", systemImage: "mappin.and.ellipse")
                                // 1件だけのときに横スクロールにしないのは、右が空いて途切れて見えるため
                                if relatedSpots.count == 1, let spot = relatedSpots.first {
                                    spotCard(spot)
                                        .padding(.horizontal, 24)
                                        .padding(.top, 8)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top, spacing: 12) {
                                            ForEach(relatedSpots) { spot in
                                                spotCard(spot)
                                                    .frame(width: screenWidth * 0.75)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                    .padding(.top, 8)
                                }
                            }

                            if yokai.story {
                                sectionHeader("物語", systemImage: "text.book.closed")
                                // ゆかりの地のカードと同じ見た目にそろえる
                                Button {
                                    Analytics.trackStoryOpened(yokaiName: yokai.name)
                                    showStoryView = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "book.pages")
                                            .font(.title2)
                                            .foregroundColor(.appSecondary)
                                            .frame(width: 44, height: 44)
                                            .background(Color.appSecondary.opacity(0.12))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        Text("\(yokai.name)の物語を読む")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    .padding(12)
                                    .background(Color.appCardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                            }
                            
                        }
                    
                        // コメント(タブに分けると気づかれにくいので、情報の下に続けて出す)
                        sectionHeader("コメント") {
                            Image("forum")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }

                        CommentListView(comments: commentVM.yokaiComments[yokai.documentId] ?? []) {
                            await commentVM.fetchYokaiComments(yokaiId: yokai.documentId)
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
                                        NeoCardItem(item: ayakasi) {
                                            selectedRelatedYokai = ayakasi
                                        }
                                        .frame(width: 160)
                                    }
                                }
                                .padding(.horizontal,20)
                                .padding(.top,12)
                            }
                        }

                        // 右下のシェア・コメントボタンに最後の要素が隠れないための余白
                        Color.clear.frame(height: 120)
                    }
                }
            }
        }
        .alert("", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .background(Color.appBackground)
        .navigationTitle(yokai.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showStoryView) {
            StoryView(yokaiName: yokai.name)
        }
        .navigationDestination(item: $selectedRelatedYokai) { yokai in
            NeoDetail(yokai: yokai, source: "related")
        }
        .task {
            Analytics.trackYokaiViewed(name: yokai.name, documentId: yokai.documentId, source: source)
            ReviewRequestManager.shared.recordActiveDay()
            await commentVM.fetchYokaiComments(yokaiId: yokai.documentId)
            // 開いた瞬間に出さないのは、妖怪を見る前に邪魔をしないため
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled, ReviewRequestManager.shared.shouldRequestReviewForActiveDays() {
                Analytics.trackReviewRequested()
                requestReview()
            }
        }
        .sheet(isPresented: $isCommentUI) {
            CommentUI(isPresented: $isCommentUI, yokai: yokai)
                .presentationDetents([.fraction(0.35)])
                .presentationBackground(.regularMaterial)
        }
        // safeAreaInsetにしないのは、縦に2つ並べたボタンの高さぶん、画面の下が常に空いてしまうため
        .overlay(alignment: .bottomTrailing) {
            BottomActionBar(
                yokai: yokai,
                isCommentUI: $isCommentUI
            )
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
