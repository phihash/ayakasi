import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class VoteService: ObservableObject {
    static let shared = VoteService()
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    //ローカルキャッシュに全ての妖怪の情報が入る
    @Published var voteCountCache: [String: Int] = [:]
    private let maxTokens = 7
    @AppStorage("voteTokens") private var availableTokens: Int = 7 // 利用可能なトークン数（最大7個）
    @AppStorage("lastRefillTime") private var lastRefillTime: Double = -1 // 最後にトークンを補充した時刻（-1は未初期化を意味）
    
    private func getCurrentMaxTokens() -> Int {
        if authService.currentUser != nil {
            return 15  // ログイン済み: 多め
        } else {
            return 7   // 未ログイン: 少なめ
        }
    }
    
    init(){
        // 初回起動時のみlastRefillTimeを現在時刻に設定
        if lastRefillTime == -1 {
            lastRefillTime = Date().timeIntervalSince1970 // 現在時刻（秒）を保存
        }
        
        Task {
            await loadAllVoteCounts()
        }
    }
    
    private func refillToken(){
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastRefill = currentTime - lastRefillTime
        
        //300秒ごとに1トークン
        let tokensToAdd = Int(timeSinceLastRefill / 300.0)
        
        if tokensToAdd > 0 {
            let currentMaxTokens = getCurrentMaxTokens()
            availableTokens = min(currentMaxTokens, tokensToAdd + availableTokens)
            lastRefillTime = currentTime
        }
    }
    
    private func canVote() -> Bool{
        refillToken()
        return availableTokens > 0
    }
    
    private func consumeToken() {
        if availableTokens > 0 {
            availableTokens -= 1
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
        guard canVote() else {
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
        consumeToken()
        
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
