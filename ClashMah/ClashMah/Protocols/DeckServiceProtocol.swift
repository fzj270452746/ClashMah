//
//  DeckServiceProtocol.swift
//  ClashMah
//
//  Refactored Architecture - Protocol Layer
//

import Foundation

/// Configuration for deck generation
struct DeckConfiguration {
    let regularTileTypes: [ZephyrTileType]
    let regularTileRange: ClosedRange<Int>
    let specialTileRange: ClosedRange<Int>
    let copiesPerTile: Int

    static let standard = DeckConfiguration(
        regularTileTypes: [.fteyd, .vnahue, .poels],
        regularTileRange: 1...9,
        specialTileRange: 1...7,
        copiesPerTile: 4
    )
}

/// Protocol for deck management operations
protocol DeckServiceProtocol {
    /// Generate a complete shuffled deck based on configuration
    func generateDeck(with configuration: DeckConfiguration) -> [ZephyrTile]

    /// Distribute tiles to players
    func distributeHands(from deck: inout [ZephyrTile], handSize: Int, playerCount: Int) -> [[ZephyrTile]]

    /// Deal tiles for middle pool
    func dealMiddlePool(from deck: inout [ZephyrTile], count: Int) -> [ZephyrTile]

    /// Shuffle remaining tiles
    func shuffle(_ tiles: inout [ZephyrTile])
}
