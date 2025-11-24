import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VoteService: ObservableObject {
    static let shared = VoteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    
    @Published var voteCounts: [String: Int] = [:]
    
    init(){
        
    }
    
    func vote(aykasiId :String) async throws{
        guard let userId = authService.currentUser?.uid else {
            throw VoteError.notAuthenticated
        }
        
//        votes/
//        └── oni/
//        ├── totalVotes: 150
//        └── users: {
//            "user123": {
//                voteCount: 3,
//                lastVotedAt: 2024-11-24 10:30:00
//            },
//            "user456": {
//                voteCount: 1,
//                lastVotedAt: 2024-11-24 09:15:00
//            }
//        }
//        
//        この構造なら：
//        - 妖怪ごとの総投票数がすぐわかる
//        - 各ユーザーの最終投票時間で連続投票を制限できる
//        - ユーザーごとの投票回数も管理できる
        
        // 2. Firestoreの参照を取得
        let voteRef = db.collection("votes").document(aykasiId)
        // 3. 既存データを取得
        let document = try await voteRef.getDocument()
        
        // 4. 現在の値を取得（なければ初期値）
        var totalVotes = document.data()?["totalVotes"] as? Int ?? 0

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
        voteCounts[aykasiId] = totalVotes

        
    }
    
    func getVoteCount(ayakasiId: String) async -> Int {
        if let count = voteCounts[ayakasiId]{
            return count
        }
        
        do {
            let document = try await db.collection("votes").document(ayakasiId).getDocument()
            let count = document.data()?["totalVotes"] as? Int ?? 0
            
            voteCounts[ayakasiId] = count
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
