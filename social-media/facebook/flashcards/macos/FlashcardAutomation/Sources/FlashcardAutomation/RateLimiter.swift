import Foundation

actor RateLimiter {
    private let capacity: Int
    private let refillRate: Double // tokens per second
    private var tokens: Double
    private var lastRefillTime: Date

    init(capacity: Int, refillRate: Double) {
        self.capacity = capacity
        self.refillRate = refillRate
        self.tokens = Double(capacity)
        self.lastRefillTime = Date()
    }

    private func refill() {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(lastRefillTime)
        let newTokens = elapsedTime * refillRate
        tokens = min(Double(capacity), tokens + newTokens)
        lastRefillTime = now
    }

    func take() async throws {
        refill()

        while tokens < 1.0 {
            let waitTime = (1.0 - tokens) / refillRate
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            refill()
        }

        tokens -= 1.0
    }
}
