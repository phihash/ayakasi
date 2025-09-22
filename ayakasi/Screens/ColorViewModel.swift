import SwiftUI

class ColorViewModel : ObservableObject{
    @Published var currentColor: Color = Color("customOrange")
    
    init(){
        let savedName = UserDefaults.standard.string(forKey: "yokaiColorName") ?? "customOrange"
        self.currentColor = Color(savedName)
    }
    
    func changeColor(colorName : String){
        self.currentColor = Color(colorName)
        UserDefaults.standard.set(colorName, forKey: "yokaiColorName")
    }
    
}
