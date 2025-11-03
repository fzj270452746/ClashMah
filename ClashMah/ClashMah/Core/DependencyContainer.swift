//
//  DependencyContainer.swift
//  ClashMah
//
//  Dependency Injection Container
//

import Foundation

final class DependencyContainer {

    // MARK: - Singleton

    static let shared = DependencyContainer()

    private init() {}

    // MARK: - Service Instances

    private(set) lazy var matchingService: TileMatchingServiceProtocol = {
        OptimizedMatchingService()
    }()

    private(set) lazy var deckService: DeckServiceProtocol = {
        StandardDeckService()
    }()

    private(set) lazy var scoreRepository: ScoreRepositoryProtocol = {
        UserDefaultsScoreRepository()
    }()

    func createAIStrategy(difficulty: AIDifficulty) -> AIStrategyProtocol {
        IntelligentAIStrategy(difficulty: difficulty, matchingService: matchingService)
    }

    // MARK: - View Model Factories

    func makeGameViewModel(for configuration: GameConfiguration) -> GameViewModel {
        let aiStrategy = createAIStrategy(difficulty: configuration.aiDifficulty)

        return GameViewModel(
            configuration: configuration,
            matchingService: matchingService,
            deckService: deckService,
            aiStrategy: aiStrategy,
            scoreRepository: scoreRepository
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(scoreRepository: scoreRepository)
    }
}
