//
//  IntelligentAIStrategy.swift
//  ClashMah
//
//  Advanced AI with Evaluation Functions and Lookahead
//

import Foundation

final class IntelligentAIStrategy: AIStrategyProtocol {
    let difficulty: AIDifficulty
    private let matchingService: TileMatchingServiceProtocol

    init(difficulty: AIDifficulty, matchingService: TileMatchingServiceProtocol) {
        self.difficulty = difficulty
        self.matchingService = matchingService
    }

    // MARK: - Public API

    func evaluateMove(
        hand: [ZephyrTile],
        availableTiles: [ZephyrTile],
        opponentHandCount: Int,
        maxHandSize: Int
    ) -> AIDecision? {
        var bestDecision: AIDecision?
        var bestScore: Double = -.infinity

        for (index, tile) in availableTiles.enumerated() {
            guard matchingService.canSelectTile(tile, with: hand, maxHandSize: maxHandSize) else {
                continue
            }

            let combinations = matchingService.detectCombinations(in: hand, with: tile)
            let optimalCombination = matchingService.selectOptimalCombination(from: combinations)

            // Evaluate this move
            let moveScore = evaluateMoveQuality(
                tile: tile,
                combination: optimalCombination,
                currentHand: hand,
                opponentHandCount: opponentHandCount
            )

            let confidence = calculateConfidence(
                score: moveScore,
                handState: hand,
                combination: optimalCombination
            )

            if moveScore > bestScore {
                bestScore = moveScore
                bestDecision = AIDecision(
                    selectedTileIndex: index,
                    targetCombination: optimalCombination,
                    confidence: confidence,
                    evaluationScore: moveScore
                )
            }
        }

        return bestDecision
    }

    func evaluateHandState(_ hand: [ZephyrTile]) -> Double {
        var score: Double = 0

        // Penalize large hand size (want to reduce tiles)
        score -= Double(hand.count) * 10

        // Reward potential combinations
        let tileFrequency = buildFrequencyMap(hand)

        for (_, count) in tileFrequency {
            switch count {
            case 4: score += 50  // Potential quad
            case 3: score += 30  // Potential triplet
            case 2: score += 15  // Potential pair
            default: break
            }
        }

        // Reward consecutive tiles (potential sequences)
        score += evaluateSequencePotential(hand) * 20

        return score
    }

    func predictOptimalCombination(for tile: ZephyrTile, in hand: [ZephyrTile]) -> TileCombination? {
        let combinations = matchingService.detectCombinations(in: hand, with: tile)
        return matchingService.selectOptimalCombination(from: combinations)
    }

    // MARK: - Private Evaluation Logic

    private func evaluateMoveQuality(
        tile: ZephyrTile,
        combination: TileCombination?,
        currentHand: [ZephyrTile],
        opponentHandCount: Int
    ) -> Double {
        var score: Double = 0

        // Factor 1: Combination value
        if let combo = combination {
            score += Double(combo.score) * 100
            score += Double(combo.tiles.count) * 50  // Prefer larger combinations
        } else {
            // No combination - less desirable
            score += 5
        }

        // Factor 2: Hand state after move
        let projectedHand: [ZephyrTile]
        if let combo = combination {
            projectedHand = matchingService.removeCombination(combo, from: currentHand)
        } else {
            projectedHand = currentHand + [tile]
        }

        score += evaluateHandState(projectedHand)

        // Factor 3: Urgency based on opponent's hand
        let urgencyMultiplier = calculateUrgency(opponentHandCount: opponentHandCount)
        score *= urgencyMultiplier

        // Factor 4: Difficulty-based randomness
        score += applyDifficultyVariance(score)

        return score
    }

    private func calculateConfidence(
        score: Double,
        handState: [ZephyrTile],
        combination: TileCombination?
    ) -> Double {
        var confidence: Double = 0.5

        // Higher confidence for good combinations
        if let combo = combination {
            confidence += Double(combo.pattern.priority) * 0.1
        }

        // Higher confidence for improving hand state
        if score > 100 {
            confidence += 0.2
        }

        // Adjust for hand size
        if handState.count <= 3 {
            confidence += 0.2
        }

        return min(max(confidence, 0), 1)
    }

    private func calculateUrgency(opponentHandCount: Int) -> Double {
        // More urgent if opponent has fewer tiles
        switch opponentHandCount {
        case 0...2: return 2.0  // Critical
        case 3...4: return 1.5  // High urgency
        case 5...6: return 1.2  // Moderate
        default: return 1.0     // Normal
        }
    }

    private func applyDifficultyVariance(_ baseScore: Double) -> Double {
        let randomFactor: Double
        switch difficulty {
        case .easy:
            // High variance - more random mistakes
            randomFactor = Double.random(in: -50...20)
        case .medium:
            // Moderate variance
            randomFactor = Double.random(in: -20...10)
        case .hard:
            // Low variance - more consistent
            randomFactor = Double.random(in: -5...5)
        }
        return randomFactor
    }

    // MARK: - Helper Methods

    private func buildFrequencyMap(_ tiles: [ZephyrTile]) -> [String: Int] {
        var freq: [String: Int] = [:]
        for tile in tiles {
            let key = "\(tile.type.rawValue)_\(tile.value)"
            freq[key, default: 0] += 1
        }
        return freq
    }

    private func evaluateSequencePotential(_ hand: [ZephyrTile]) -> Double {
        let regularTiles = hand.filter { $0.type.isRegular }
        let groupedByType = Dictionary(grouping: regularTiles) { $0.type }

        var potential: Double = 0

        for (_, tiles) in groupedByType {
            let values = Set(tiles.map { $0.value })

            // Check for consecutive patterns
            for value in values {
                if values.contains(value + 1) || values.contains(value - 1) {
                    potential += 0.5
                }
                if values.contains(value + 1) && values.contains(value + 2) {
                    potential += 1.0
                }
            }
        }

        return potential
    }
}
