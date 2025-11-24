import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VoteService: ObservableObject {
    static let shared = VoteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    
    @Published var voteCounts: [String: Int] = [:]
    
    private init(){
        
    }
    
 
}
