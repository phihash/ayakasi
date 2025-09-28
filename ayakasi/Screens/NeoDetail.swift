import SwiftUI
import Photos

struct NeoDetail: View {
    let yokai : Ayakasi
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showFullScreenImage = false
    @State private var showAlert : Bool = false
    @State private var alertMessage : String = ""
    @EnvironmentObject var colorVM : ColorViewModel
    
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
        guard let uiImage = UIImage(named:imageName) else  { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
        }){success, error in
            DispatchQueue.main.async{
                if success {
                    alertMessage = "保存しました"
                    showAlert = true
                } else {
                    alertMessage = "保存失敗しました"
                    showAlert = true
                }
            }
        }
    }
    
    var body: some View {
        ZStack{
            ScrollView{
                
                VStack{
                    ZStack{
                        Image(yokai.imageName)
                            .resizable()
                            .scaledToFill()
                        
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
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom,28)
                            .padding(.leading,32)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    
                    // 2タブ
                    HStack{
                        Text("基本情報")
                            .fontWeight(.bold)
                            .padding(.vertical,16)
                            .foregroundStyle(selectedTab == 0 ? colorVM.currentColor : .black.opacity(0.3))
                            .frame(width: screenWidth * 0.45)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .frame(height: 2)
                                    .frame(width: screenWidth * 0.45)
                                    .foregroundStyle(selectedTab == 0 ? colorVM.currentColor : .black.opacity(0.3))
                            }
                            .onTapGesture {
                                selectedTab = 0
                            }
                        
                        Text("その他")
                            .fontWeight(.bold)
                            .padding(.vertical,16)
                            .foregroundStyle(selectedTab == 1 ? colorVM.currentColor : .black.opacity(0.3))
                            .frame(width: screenWidth * 0.45)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .frame(height: 2)
                                    .frame(width: screenWidth * 0.45)
                                    .foregroundStyle(selectedTab == 1 ? colorVM.currentColor : .black.opacity(0.4))
                            }
                            .onTapGesture {
                                selectedTab = 1
                            }
                    }
                    .padding(.vertical,8)
                    .padding(.horizontal,8)
                    
                    VStack{
                        //基本情報たぶ
                        if selectedTab == 0{
                            ScrollView(showsIndicators: false){
                                VStack{
                                    HStack{
                                        Image("description")
                                            .renderingMode(.template)
                                        Text("説明")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }
                                    .padding(.vertical,12)
                                    
                                    Text(yokai.description)
                                        .fontWeight(.bold)
                                        .padding(.vertical,6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    
                                }
                                .padding(.horizontal,24)
                                
                            }
                        } else{
                            
                            ScrollView(showsIndicators: false){
                                
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
                                        .padding(.bottom,12)
                                        
                                        Text(episodes)
                                            .fontWeight(.bold)
                                            .padding(.vertical,4)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                    }
                                    .padding(.horizontal,24)
                                }
                                
                                if let btw = yokai.btw {
                                    VStack{
                                        ByTheWay(btw: btw)
                                    }
                                }
                            }
                            .padding(.bottom,16)
                            
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
        .safeAreaInset(edge: .bottom){
            VStack{
                
                HStack{
                    
                    HStack{
                        Text("写真を保存")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: screenWidth * 0.6, height: 44)
                    .background(Capsule().fill(colorVM.currentColor))
                    .padding(.trailing,32)
                    .onTapGesture {
                        requestAndSaveImage(imageName: yokai.imageName)
                    }
                    
                    
                    VStack(spacing:4){
                        Image(systemName: "arrowshape.turn.up.backward")
                        Text("戻る")
                            .font(.subheadline)
                    }.onTapGesture {
                        dismiss()
                    }
                    
                    
                }
                .padding(.top,16)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(.white)
            
        }
        
    }
}
