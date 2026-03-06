import SwiftUI

protocol TokenBucketProtocol {
    //消費できるかどうかだけわければよい
    func canConsume() -> Bool
    // 実際に消費する
    func consume() -> Void
}

class TokenBucket : TokenBucketProtocol{
    
    private let maxToken : Int
    private let refillInterval : Int
    @AppStorage private var availableToken: Int
    @AppStorage private var lastRefillTime: Double
    
    init(maxToken: Int, refillInterval: Int, storageKeyPrefix: String) {
        self.maxToken = maxToken
        self.refillInterval = refillInterval
        _availableToken = AppStorage(wrappedValue: maxToken, "\(storageKeyPrefix)Tokens")
        _lastRefillTime = AppStorage(wrappedValue: -1, "\(storageKeyPrefix)RefillTime")
    }
    
    
    private func refillToken(){
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastRefill = currentTime - lastRefillTime
        
        let tokensToAdd = Int(timeSinceLastRefill / Double(refillInterval))
        if tokensToAdd > 0 {
            availableToken = min(maxToken, tokensToAdd + availableToken)
            lastRefillTime = currentTime
        }
    }
    
    func canConsume() -> Bool {
        refillToken()
        return availableToken > 0
    }
    
    func consume() {
        if availableToken > 0 {
            availableToken -= 1  
        }
    }
    
}
