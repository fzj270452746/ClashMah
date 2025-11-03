//
//  GameViewModel.swift
//  ClashMah
//
//  MVVM Architecture - Game Logic Layer
//

import Foundation
import Combine

// MARK: - Game Events

enum GameEvent {
    case roundStarted
    case tileSelected(index: Int)
    case combinationFormed(TileCombination)
    case turnChanged(PlayerType)
    case middlePoolRefreshed
    case roundCompleted(winner: PlayerType)
    case gameCompleted(winner: PlayerType, statistics: GameStatistics)
}

// MARK: - Player Type

enum PlayerType {
    case player
    case ai

    var displayName: String {
        switch self {
        case .player: return "You"
        case .ai: return "Computer"
        }
    }
}

// MARK: - Game Configuration

struct GameConfiguration {
    let mode: AxiomGameMode
    let aiDifficulty: AIDifficulty
    let playerCount: Int

    static func standard(mode: AxiomGameMode) -> GameConfiguration {
        GameConfiguration(mode: mode, aiDifficulty: .medium, playerCount: 2)
    }
}

// MARK: - Game View Model

final class GameViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var playerHand: [ZephyrTile] = []
    @Published private(set) var aiHand: [ZephyrTile] = []
    @Published private(set) var middlePool: [ZephyrTile] = []
    @Published private(set) var currentTurn: PlayerType = .player
    @Published private(set) var statusMessage: String = ""
    @Published private(set) var selectedTileIndex: Int?
    @Published private(set) var roundNumber: Int = 0
    @Published private(set) var playerScore: Int = 0
    @Published private(set) var aiScore: Int = 0
    @Published private(set) var isGameActive: Bool = false

    // MARK: - Event Publisher

    let eventPublisher = PassthroughSubject<GameEvent, Never>()

    // MARK: - Dependencies

    private let configuration: GameConfiguration
    private let matchingService: TileMatchingServiceProtocol
    private let deckService: DeckServiceProtocol
    private let aiStrategy: AIStrategyProtocol
    private let scoreRepository: ScoreRepositoryProtocol

    private var remainingDeck: [ZephyrTile] = []
    private var gameStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        configuration: GameConfiguration,
        matchingService: TileMatchingServiceProtocol,
        deckService: DeckServiceProtocol,
        aiStrategy: AIStrategyProtocol,
        scoreRepository: ScoreRepositoryProtocol
    ) {
        self.configuration = configuration
        self.matchingService = matchingService
        self.deckService = deckService
        self.aiStrategy = aiStrategy
        self.scoreRepository = scoreRepository
    }

    // MARK: - Game Lifecycle

    func startNewGame() {
        resetGameState()
        startNewRound()
        gameStartTime = Date()
        isGameActive = true
    }

    func startNewRound() {
        remainingDeck = deckService.generateDeck(with: .standard)

        let hands = deckService.distributeHands(
            from: &remainingDeck,
            handSize: configuration.mode.handSize,
            playerCount: configuration.playerCount
        )

        playerHand = sortTiles(hands[0])
        aiHand = hands[1]

        middlePool = deckService.dealMiddlePool(
            from: &remainingDeck,
            count: configuration.mode.totalMiddleCards
        )

        currentTurn = .player
        selectedTileIndex = nil
        roundNumber += 1

        updateStatusMessage("Your turn - Select a tile")
        eventPublisher.send(.roundStarted)
    }

    // MARK: - Player Actions

    func selectTile(at index: Int) {
        guard currentTurn == .player,
              index < middlePool.count,
              isGameActive else {
            return
        }

        let tile = middlePool[index]

        // Check if can select
        guard matchingService.canSelectTile(tile, with: playerHand, maxHandSize: configuration.mode.handSize) else {
            updateStatusMessage("Cannot select: Hand is full and no valid combination!")
            return
        }

        // Already selected? Confirm selection
        if selectedTileIndex == index {
            confirmTileSelection(at: index)
            return
        }

        // Update selection
        selectedTileIndex = index
        let combinations = matchingService.detectCombinations(in: playerHand, with: tile)

        if combinations.isEmpty {
            updateStatusMessage("Selected. Tap again to pick this tile.")
        } else {
            let description = combinations.map { describePattern($0.pattern) }.joined(separator: ", ")
            updateStatusMessage("Can form: \(description). Tap again to confirm.")
        }

        eventPublisher.send(.tileSelected(index: index))
    }

    func skipTurn() {
        guard currentTurn == .player, isGameActive else { return }
        endPlayerTurn()
    }

    // MARK: - AI Turn

    private func executeAITurn() {
        currentTurn = .ai
        updateStatusMessage("\(PlayerType.ai.displayName) is thinking...")

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.aiDifficulty.thinkingTime) { [weak self] in
            self?.performAIMove()
        }
    }

    private func performAIMove() {
        guard let decision = aiStrategy.evaluateMove(
            hand: aiHand,
            availableTiles: middlePool,
            opponentHandCount: playerHand.count,
            maxHandSize: configuration.mode.handSize
        ) else {
            // AI skips
            endAITurn()
            return
        }

        let selectedTile = middlePool[decision.selectedTileIndex]

        if let combination = decision.targetCombination {
            // AI forms combination
            aiHand = matchingService.removeCombination(combination, from: aiHand)
            middlePool.remove(at: decision.selectedTileIndex)

            updateStatusMessage("\(PlayerType.ai.displayName) formed \(describePattern(combination.pattern))!")
            eventPublisher.send(.combinationFormed(combination))

            if aiHand.isEmpty {
                handleRoundCompletion(winner: .ai)
                return
            }
        } else {
            // AI just picks tile
            aiHand.append(selectedTile)
            middlePool.remove(at: decision.selectedTileIndex)
        }

        endAITurn()
    }

    // MARK: - Private Game Logic

    private func confirmTileSelection(at index: Int) {
        let tile = middlePool[index]
        let combinations = matchingService.detectCombinations(in: playerHand, with: tile)

        if let combination = matchingService.selectOptimalCombination(from: combinations) {
            // Form combination
            playerHand = matchingService.removeCombination(combination, from: playerHand)
            middlePool.remove(at: index)
            playerHand = sortTiles(playerHand)

            updateStatusMessage("Formed \(describePattern(combination.pattern))!")
            eventPublisher.send(.combinationFormed(combination))

            if playerHand.isEmpty {
                handleRoundCompletion(winner: .player)
                return
            }
        } else {
            // Just add to hand
            playerHand.append(tile)
            middlePool.remove(at: index)
            playerHand = sortTiles(playerHand)
        }

        selectedTileIndex = nil
        endPlayerTurn()
    }

    private func endPlayerTurn() {
        refreshMiddlePool()
        executeAITurn()
    }

    private func endAITurn() {
        refreshMiddlePool()
        currentTurn = .player
        updateStatusMessage("Your turn - Select a tile")
        eventPublisher.send(.turnChanged(.player))
    }

    private func refreshMiddlePool() {
        // Return middle pool to deck and reshuffle
        remainingDeck.append(contentsOf: middlePool)
        deckService.shuffle(&remainingDeck)

        middlePool = deckService.dealMiddlePool(
            from: &remainingDeck,
            count: configuration.mode.totalMiddleCards
        )

        eventPublisher.send(.middlePoolRefreshed)
    }

    private func handleRoundCompletion(winner: PlayerType) {
        isGameActive = false

        switch winner {
        case .player:
            playerScore += 1
        case .ai:
            aiScore += 1
        }

        eventPublisher.send(.roundCompleted(winner: winner))

        // Check if game is complete
        if configuration.mode == .challenge {
            if roundNumber >= 5 {
                handleGameCompletion()
            }
        } else {
            handleGameCompletion()
        }
    }

    private func handleGameCompletion() {
        let winner: PlayerType = playerScore > aiScore ? .player : .ai
        let duration = Date().timeIntervalSince(gameStartTime ?? Date())

        scoreRepository.recordGameResult(
            mode: configuration.mode,
            playerWon: winner == .player,
            duration: duration
        )

        let statistics = scoreRepository.fetchStatistics()
        eventPublisher.send(.gameCompleted(winner: winner, statistics: statistics))
    }

    // MARK: - Helper Methods

    private func resetGameState() {
        playerHand = []
        aiHand = []
        middlePool = []
        remainingDeck = []
        roundNumber = 0
        playerScore = 0
        aiScore = 0
        selectedTileIndex = nil
        currentTurn = .player
    }

    private func sortTiles(_ tiles: [ZephyrTile]) -> [ZephyrTile] {
        let typeOrder: [ZephyrTileType: Int] = [.fteyd: 0, .vnahue: 1, .poels: 2, .oeiue: 3]

        return tiles.sorted { lhs, rhs in
            let lhsOrder = typeOrder[lhs.type] ?? Int.max
            let rhsOrder = typeOrder[rhs.type] ?? Int.max

            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }
            return lhs.value < rhs.value
        }
    }

    private func updateStatusMessage(_ message: String) {
        statusMessage = message
    }

    private func describePattern(_ pattern: CombinationPattern) -> String {
        switch pattern {
        case .pair: return "Pair"
        case .triplet: return "Triplet"
        case .sequence: return "Sequence"
        case .quad: return "Quad"
        }
    }
}
