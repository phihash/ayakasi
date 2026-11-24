import SwiftUI
import StoreKit
import Photos
import Kingfisher

struct CommentListView: View {
    let comments: [YokaiComment]
    let onChanged: () async -> Void

    var body: some View {
        if comments.isEmpty {
            CommentEmptyState()
                .padding(.vertical, 24)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(comments) { comment in
                    CommentCard(comment: comment, onChanged: onChanged)
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
    #if DEBUG
    @State private var visitComposer: VisitComposerContext?
    #endif
    @State private var selectedRelatedYokai: Ayakasi? = nil
    // .task は関連妖怪などから戻るたびに走るので、閲覧の計測は1回だけにする
    @State private var didRecordView = false
    @EnvironmentObject var commentVM : CommentService
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
                        .appFont(.subheadline)
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
            .appFont(.title)
            .fontWeight(.bold)
            .padding(.bottom, 20)
            .padding(.leading, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
    
    @ViewBuilder
    private var imageMetadata: some View {
        let source = yokai.imageSource ?? ""
        let tags = yokai.categories.filter { !$0.isEmpty && $0 != "すべて" }.map { "#\($0)" }
        let credit = [yokai.imageAuthor, yokai.imageTitle].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "　")

        if !source.isEmpty || !tags.isEmpty || !credit.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                if !source.isEmpty || !tags.isEmpty {
                    let labels = Group {
                        if !source.isEmpty {
                            Text(source)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appTextSecondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }
                        if !tags.isEmpty {
                            Text(tags.joined(separator: "  "))
                        }
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) { labels }
                        VStack(alignment: .leading, spacing: 4) { labels }
                    }
                }
                if !credit.isEmpty {
                    Text(credit)
                        .fontWeight(.medium)
                }
            }
            .appFont(.caption)
            .foregroundStyle(Color.appTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        sectionHeader(title) { Image(systemName: systemImage) }
    }

    private func sectionHeader(_ title: String, @ViewBuilder icon: () -> some View) -> some View {
        HStack {
            icon()
            Text(title)
                .appFont(.title3)
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

    private func spotCard(_ spot: YokaiSpot) -> some View {
        HStack(alignment: .top, spacing: 12) {
            YokaiThumbnail(yokai: yokaiById(spot.yokaiIds.first ?? "") ?? yokai, size: 96)

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.spotName)
                    .appFont(.headline)
                    .foregroundColor(.appTextPrimary)
                Text(spot.prefecture)
                    .appFont(.caption)
                    .foregroundColor(.appTextSecondary)
                if let description = spot.description {
                    Text(description)
                        .appFont(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 2)
                }
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
                    
                    imageMetadata

                    Group {
                        VStack{
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

                                #if DEBUG
                                SpotVisitSection(yokaiId: yokai.documentId, spots: relatedSpots, composer: $visitComposer)
                                    .id(yokai.documentId)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 8)
                                #endif
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
                                            .appFont(.title2)
                                            .foregroundColor(.appSecondary)
                                            .frame(width: 44, height: 44)
                                            .background(Color.appSecondary.opacity(0.12))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        Text("\(yokai.name)の物語を読む")
                                            .appFont(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .appFont(.caption)
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
                                    .appFont(.title3)
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(yokai.name)
                    .appFont(.callout, weight: .semibold)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .fullScreenCover(isPresented: $showStoryView) {
            StoryView(yokaiName: yokai.name)
        }
        .navigationDestination(item: $selectedRelatedYokai) { yokai in
            NeoDetail(yokai: yokai, source: "related")
        }
        .task {
            if !didRecordView {
                didRecordView = true
                Analytics.trackYokaiViewed(name: yokai.name, documentId: yokai.documentId, source: source)
                ReviewRequestManager.shared.recordYokaiViewed()
            }
            await commentVM.fetchYokaiComments(yokaiId: yokai.documentId)
            // 開いた瞬間に出さないのは、妖怪を見る前に邪魔をしないため
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled, ReviewRequestManager.shared.shouldRequestReview() {
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
            VStack(alignment: .trailing, spacing: 10) {
                #if DEBUG
                if let relatedSpots = yokai.relatedSpots, !relatedSpots.isEmpty {
                    VisitComposeButton(yokaiId: yokai.documentId, spots: relatedSpots, composer: $visitComposer)
                        .padding(.trailing, 22)
                }
                #endif
                BottomActionBar(
                    yokai: yokai,
                    isCommentUI: $isCommentUI
                )
            }
            #if DEBUG
            .opacity(visitComposer == nil ? 1 : 0)
            .allowsHitTesting(visitComposer == nil)
            .accessibilityHidden(visitComposer != nil)
            #endif
        }
        #if DEBUG
        .visitComposer($visitComposer)
        #endif
        .toolbar(.hidden, for: .tabBar)
    }
}
