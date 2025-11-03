//
//  HomeViewModel.swift
//  ClashMah
//
//  MVVM Architecture - Home Screen Logic
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var statistics: GameStatistics = .initial
    @Published private(set) var isLoading: Bool = false

    // MARK: - Dependencies

    private let scoreRepository: ScoreRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(scoreRepository: ScoreRepositoryProtocol) {
        self.scoreRepository = scoreRepository
        loadStatistics()
    }

    // MARK: - Public Methods

    func loadStatistics() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let stats = self.scoreRepository.fetchStatistics()

            DispatchQueue.main.async {
                self.statistics = stats
                self.isLoading = false
            }
        }
    }

    func submitFeedback(_ content: String, rating: Int? = nil) {
        let feedback = FeedbackEntry(content: content, rating: rating)
        scoreRepository.saveFeedback(feedback)
    }

    func resetStatistics() {
        scoreRepository.resetAllData()
        loadStatistics()
    }

    // MARK: - Computed Properties

    var normalModeWinsText: String {
        "Normal Mode Wins: \(statistics.normalModeWins)"
    }

    var challengeModeWinsText: String {
        "Challenge Mode Wins: \(statistics.challengeModeWins)"
    }

    var challengeModeLossesText: String {
        "Challenge Mode Losses: \(statistics.challengeModeLosses)"
    }

    var winRateText: String {
        let percentage = Int(statistics.winRate * 100)
        return "Win Rate: \(percentage)%"
    }

    var longestStreakText: String {
        "Longest Win Streak: \(statistics.longestWinStreak)"
    }
}
