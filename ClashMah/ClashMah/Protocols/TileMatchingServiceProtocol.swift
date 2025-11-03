//
//  TileMatchingServiceProtocol.swift
//  ClashMah
//
//  Refactored Architecture - Protocol Layer
//

import Foundation

/// Represents a combination pattern of tiles
enum CombinationPattern: Comparable {
    case pair
    case sequence
    case triplet
    case quad

    static func < (lhs: CombinationPattern, rhs: CombinationPattern) -> Bool {
        if lhs.tileCount == rhs.tileCount {
            return lhs.priority < rhs.priority
        }
        return lhs.tileCount < rhs.tileCount
    }

    var tileCount: Int {
        switch self {
        case .pair: return 2
        case .sequence: return 3
        case .triplet: return 3
        case .quad: return 4
        }
    }

    var priority: Int {
        switch self {
        case .quad: return 4
        case .triplet: return 3
        case .sequence: return 2
        case .pair: return 1
        }
    }
}

/// Represents a valid tile combination
struct TileCombination: Equatable {
    let pattern: CombinationPattern
    let tiles: [ZephyrTile]
    let score: Int

    init(pattern: CombinationPattern, tiles: [ZephyrTile]) {
        self.pattern = pattern
        self.tiles = tiles
        self.score = pattern.priority * tiles.count
    }
}

/// Protocol for tile matching and combination detection
protocol TileMatchingServiceProtocol {
    /// Detect all valid combinations when adding a new tile to hand
    func detectCombinations(in hand: [ZephyrTile], with newTile: ZephyrTile) -> [TileCombination]

    /// Check if a tile can be legally selected
    func canSelectTile(_ tile: ZephyrTile, with hand: [ZephyrTile], maxHandSize: Int) -> Bool

    /// Remove combination tiles from hand and return updated hand
    func removeCombination(_ combination: TileCombination, from hand: [ZephyrTile]) -> [ZephyrTile]

    /// Select optimal combination from available options
    func selectOptimalCombination(from combinations: [TileCombination]) -> TileCombination?
}
