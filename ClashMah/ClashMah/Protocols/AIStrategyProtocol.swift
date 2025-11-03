//
//  AIStrategyProtocol.swift
//  ClashMah
//
//  Refactored Architecture - Protocol Layer
//

import Foundation

/// Represents AI difficulty levels
enum AIDifficulty: Int {
    case easy = 1
    case medium = 2
    case hard = 3

    var thinkingTime: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 1.0
        case .hard: return 1.5
        }
    }

    var evaluationDepth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

/// Represents an AI decision
struct AIDecision {
    let selectedTileIndex: Int
    let targetCombination: TileCombination?
    let confidence: Double
    let evaluationScore: Double

    var shouldSkip: Bool {
        return confidence < 0.3
    }
}

/// Protocol for AI strategy implementation
protocol AIStrategyProtocol {
    var difficulty: AIDifficulty { get }

    /// Evaluate all available moves and select the best one
    func evaluateMove(
        hand: [ZephyrTile],
        availableTiles: [ZephyrTile],
        opponentHandCount: Int,
        maxHandSize: Int
    ) -> AIDecision?

    /// Calculate the value/score of a hand state
    func evaluateHandState(_ hand: [ZephyrTile]) -> Double

    /// Predict optimal combination strategy
    func predictOptimalCombination(
        for tile: ZephyrTile,
        in hand: [ZephyrTile]
    ) -> TileCombination?
}
