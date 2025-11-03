//
//  UserDefaultsScoreRepository.swift
//  ClashMah
//
//  Persistent Storage with Repository Pattern
//

import Foundation

final class UserDefaultsScoreRepository: ScoreRepositoryProtocol {

    // MARK: - Storage Keys

    private enum StorageKey: String {
        case statistics = "com.clashmah.statistics"
        case feedbackEntries = "com.clashmah.feedback"
    }

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Statistics Management

    func fetchStatistics() -> GameStatistics {
        guard let data = userDefaults.data(forKey: StorageKey.statistics.rawValue),
              let statistics = try? JSONDecoder().decode(GameStatistics.self, from: data) else {
            return .initial
        }
        return statistics
    }

    func recordGameResult(mode: AxiomGameMode, playerWon: Bool, duration: TimeInterval) {
        var stats = fetchStatistics()

        stats.totalGamesPlayed += 1

        // Update mode-specific statistics
        switch mode {
        case .normal:
            if playerWon {
                stats.normalModeWins += 1
                stats.currentWinStreak += 1
            } else {
                stats.normalModeLosses += 1
                stats.currentWinStreak = 0
            }
        case .challenge:
            if playerWon {
                stats.challengeModeWins += 1
                stats.currentWinStreak += 1
            } else {
                stats.challengeModeLosses += 1
                stats.currentWinStreak = 0
            }
        }

        // Update longest win streak
        if stats.currentWinStreak > stats.longestWinStreak {
            stats.longestWinStreak = stats.currentWinStreak
        }

        // Update average game duration
        let totalDuration = stats.averageGameDuration * Double(stats.totalGamesPlayed - 1) + duration
        stats.averageGameDuration = totalDuration / Double(stats.totalGamesPlayed)

        saveStatistics(stats)
    }

    // MARK: - Feedback Management

    func saveFeedback(_ feedback: FeedbackEntry) {
        var entries = fetchAllFeedback()
        entries.append(feedback)

        if let data = try? JSONEncoder().encode(entries) {
            userDefaults.set(data, forKey: StorageKey.feedbackEntries.rawValue)
        }
    }

    func fetchAllFeedback() -> [FeedbackEntry] {
        guard let data = userDefaults.data(forKey: StorageKey.feedbackEntries.rawValue),
              let entries = try? JSONDecoder().decode([FeedbackEntry].self, from: data) else {
            return []
        }
        return entries
    }

    // MARK: - Data Management

    func resetAllData() {
        userDefaults.removeObject(forKey: StorageKey.statistics.rawValue)
        userDefaults.removeObject(forKey: StorageKey.feedbackEntries.rawValue)
    }

    // MARK: - Private Helpers

    private func saveStatistics(_ statistics: GameStatistics) {
        if let data = try? JSONEncoder().encode(statistics) {
            userDefaults.set(data, forKey: StorageKey.statistics.rawValue)
        }
    }
}
