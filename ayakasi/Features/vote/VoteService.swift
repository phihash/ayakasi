import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VoteService: ObservableObject {
    static let shared = VoteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    //ローカルキャッシュに全ての妖怪の情報が入る
    @Published var voteCountCache: [String: Int] = [:]
    
    init(){
        Task {
            await loadAllVoteCounts()
        }
    }
    
    private func loadAllVoteCounts() async {
        do {
            //DBの参照先
            //これ自体がエラーをなげうる、呼び出し元に波及させたくないのでdo catch
            let votesSnapshot = try await db.collection("votes").getDocuments()
            // ayakasiId : count
            var newCache: [String: Int] = [:]
            
            for document in votesSnapshot.documents {
                let ayakasiId = document.documentID
                let totalVotes = document.data()["totalVotes"] as? Int ?? 0
                newCache[ayakasiId] = totalVotes
            }
            
            self.voteCountCache = newCache
            
        } catch {
            print("全投票数取得エラー: \(error)")
        }
    }
    
    func vote(aykasiId :String) async throws{
        //        認証されたユーザーであるか?ユーザーIDがあるかなければエラー
        guard let userId = authService.currentUser?.uid else {
            throw VoteError.notAuthenticated
        }
        // キャッシュから現在の投票数を取得
        var totalVotes = voteCountCache[aykasiId] ?? 0
        
        // 5. 総投票数を増加
        totalVotes += 1
        
        // ユーザー情報を取得するため、該当ドキュメントを取得
        let voteRef = db.collection("votes").document(aykasiId)
        let document = try await voteRef.getDocument()
        var users = document.data()?["users"] as? [String: [String:Any] ] ?? [:]
        let userVoteCount = (users[userId]?["voteCount"] as? Int ?? 0) + 1
        
        users[userId] = [
            "voteCount" : userVoteCount,
            "lastVotedAt" : Timestamp(date: Date())
        ]
        
        // Firestoreに保存
        try await voteRef.setData(["totalVotes": totalVotes,"users":users],merge:true)
        
        // キャッシュを更新
        voteCountCache[aykasiId] = totalVotes
        
        
    }
}

enum VoteError: Error {
    case notAuthenticated
}
