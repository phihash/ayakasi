import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VoteService: ObservableObject {
    static let shared = VoteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    @Published var voteCountCache: [String: Int] = [:]
    
    init(){
        
    }
    
    func vote(aykasiId :String) async throws{
        guard let userId = authService.currentUser?.uid else {
            throw VoteError.notAuthenticated
        }
        
        // 2. Firestoreの参照を取得
        let voteRef = db.collection("votes").document(aykasiId)
        // 3. 既存データを取得
        let document = try await voteRef.getDocument()
        
        // 4. 現在の値を取得（なければ初期値）
        var totalVotes = document.data()?["totalVotes"] as? Int ?? 0
        
        // キャッシュも最新値に更新（投票前に表示を正確にする）
        voteCountCache[aykasiId] = totalVotes
        
        // 5. 総投票数を増加
        totalVotes += 1
        
        //6そのユーザーの投票した数をGET!
        var users = document.data()?["users"] as? [String: [String:Any] ] ?? [:]
        let userVoteCount = (users[userId]?["voteCount"] as? Int ?? 0) + 1
        
        users[userId] = [
            "voteCount" : userVoteCount,
            "lastVotedAt" : Timestamp(date: Date())
        ]
        
        //7
        try await voteRef.setData(["totalVotes": totalVotes,"users":users],merge:true);
        
        // 投票後に最新の値を取得し直す
        let updatedDocument = try await voteRef.getDocument()
        let actualCount = updatedDocument.data()?["totalVotes"] as? Int ?? totalVotes
        voteCountCache[aykasiId] = actualCount
        
        
    }
    
    func getVoteCount(ayakasiId: String) async -> Int {
        if let count = voteCountCache[ayakasiId]{
            return count
        }
        
        do {
            let document = try await db.collection("votes").document(ayakasiId).getDocument()
            let count = document.data()?["totalVotes"] as? Int ?? 0
            
            voteCountCache[ayakasiId] = count
            return count
        }catch{
            print("投票数取得エラー: \(error)")
            return 0
        }
    }
}

enum VoteError: Error {
    case notAuthenticated
}
