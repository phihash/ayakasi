import SwiftUI

struct Container: View {
    @State private var selection : Int = 0
    @EnvironmentObject var colorVM : ColorViewModel
    var body: some View {
        ZStack{
            
            TabView(selection: $selection) {

                SearchView()
                    .tabItem {
                        Image("search")
                            .renderingMode(.template)
                    }
                    .tag(0)
                
                HomeView()
                    .tabItem {
                        Image("news")
                            .renderingMode(.template)
                    }
                    .tag(1)
                
                
                CommunityView()
                    .tabItem {
                        Image("comment")
                            .renderingMode(.template)
                    }
                    .tag(2)
//                
                JapanView()
                    .tabItem {
                        Image("locationcity")
                            .renderingMode(.template)
                    }
                    .tag(3)
              
                SettingView()
                    .tabItem {
                        Image("setting")
                            .renderingMode(.template)
                    }
                    .tag(4)
                
            }
            .tint(colorVM.currentColor)
        }
    }
}

