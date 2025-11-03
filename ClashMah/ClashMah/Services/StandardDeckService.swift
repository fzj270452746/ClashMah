//
//  StandardDeckService.swift
//  ClashMah
//
//  Protocol-Based Deck Management Service
//

import Foundation

final class StandardDeckService: DeckServiceProtocol {

    // MARK: - Deck Generation

    func generateDeck(with configuration: DeckConfiguration = .standard) -> [ZephyrTile] {
        var tiles: [ZephyrTile] = []

        // Generate regular tiles
        for tileType in configuration.regularTileTypes {
            for value in configuration.regularTileRange {
                for _ in 0..<configuration.copiesPerTile {
                    tiles.append(ZephyrTile(type: tileType, value: value))
                }
            }
        }

        // Generate special tiles
        for value in configuration.specialTileRange {
            for _ in 0..<configuration.copiesPerTile {
                tiles.append(ZephyrTile(type: .oeiue, value: value))
            }
        }

        // Shuffle using Fisher-Yates algorithm
        return tiles.shuffled()
    }

    // MARK: - Distribution

    func distributeHands(from deck: inout [ZephyrTile], handSize: Int, playerCount: Int) -> [[ZephyrTile]] {
        var hands: [[ZephyrTile]] = Array(repeating: [], count: playerCount)

        for playerIndex in 0..<playerCount {
            for _ in 0..<handSize where !deck.isEmpty {
                hands[playerIndex].append(deck.removeFirst())
            }
        }

        return hands
    }

    func dealMiddlePool(from deck: inout [ZephyrTile], count: Int) -> [ZephyrTile] {
        var pool: [ZephyrTile] = []

        for _ in 0..<count where !deck.isEmpty {
            pool.append(deck.removeFirst())
        }

        return pool
    }

    func shuffle(_ tiles: inout [ZephyrTile]) {
        tiles.shuffle()
    }
}
