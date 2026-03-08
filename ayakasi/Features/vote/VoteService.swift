import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class VoteService: ObservableObject {

    private let db = Firestore.firestore()
    private let authService : AuthServiceProtocol
    //ローカルキャッシュに全ての妖怪の情報が入る
    @Published var voteCountCache: [String: Int] = [:]

    private let tokenBucket: TokenBucketProtocol
    init(authService: AuthServiceProtocol, tokenBucket: TokenBucketProtocol) {
        self.authService = authService
        self.tokenBucket = tokenBucket
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
        //認証されたユーザーであるか?ユーザーIDがあるかなければエラー
//        guard let userId = authService.currentUser?.uid else {
//            throw VoteError.notAuthenticated
//        }
//        
        // レートリミットcheck
        guard tokenBucket.canConsume()   else {
            throw VoteError.rateLimitExceeded
        }
        
        let voteRef = db.collection("votes").document(aykasiId)
        
        let result = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let document = try transaction.getDocument(voteRef)
                let currentVotes = document.data()?["totalVotes"] as? Int ?? 0
                let updatedVotes = currentVotes + 1
                
                transaction.setData(["totalVotes": updatedVotes], forDocument: voteRef, merge: true)
                return updatedVotes
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
        
        let newVotes = result as? Int ?? 0
        
        // 投票成功時のみトークンを消費
        tokenBucket.consume()
        
        voteCountCache[aykasiId] = newVotes

    }
    
    func getVoteCount(ayakasiId: String) -> Int {
        return voteCountCache[ayakasiId] ?? 0
    }
    
}

enum VoteError: Error, LocalizedError {
    case notAuthenticated
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "ログインが必要です"
        case .rateLimitExceeded:
            return "投票回数の上限に達しました、しばらく待って再度投票してください"
        }
    }
}
