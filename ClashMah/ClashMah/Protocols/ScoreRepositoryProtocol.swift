//
//  ScoreRepositoryProtocol.swift
//  ClashMah
//
//  Refactored Architecture - Protocol Layer
//

import Foundation

/// Represents game statistics
struct GameStatistics: Codable {
    var normalModeWins: Int
    var normalModeLosses: Int
    var challengeModeWins: Int
    var challengeModeLosses: Int
    var totalGamesPlayed: Int
    var averageGameDuration: TimeInterval
    var longestWinStreak: Int
    var currentWinStreak: Int

    static let initial = GameStatistics(
        normalModeWins: 0,
        normalModeLosses: 0,
        challengeModeWins: 0,
        challengeModeLosses: 0,
        totalGamesPlayed: 0,
        averageGameDuration: 0,
        longestWinStreak: 0,
        currentWinStreak: 0
    )

    var winRate: Double {
        let totalWins = normalModeWins + challengeModeWins
        guard totalGamesPlayed > 0 else { return 0 }
        return Double(totalWins) / Double(totalGamesPlayed)
    }
}

/// User feedback entry
struct FeedbackEntry: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let content: String
    let rating: Int?

    init(content: String, rating: Int? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.content = content
        self.rating = rating
    }
}

/// Protocol for persistent storage operations
protocol ScoreRepositoryProtocol {
    /// Fetch current game statistics
    func fetchStatistics() -> GameStatistics

    /// Update statistics with new game result
    func recordGameResult(mode: AxiomGameMode, playerWon: Bool, duration: TimeInterval)

    /// Save user feedback
    func saveFeedback(_ feedback: FeedbackEntry)

    /// Retrieve all feedback entries
    func fetchAllFeedback() -> [FeedbackEntry]

    /// Clear all stored data
    func resetAllData()
}
