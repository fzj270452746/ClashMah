//
//  OptimizedMatchingService.swift
//  ClashMah
//
//  High-Performance Tile Matching Engine
//  Complexity: O(n) using hash-based lookups instead of O(n^4) nested loops
//

import Foundation

final class OptimizedMatchingService: TileMatchingServiceProtocol {

    // MARK: - Hash-Based Tile Lookup (O(1) access)

    private struct TileKey: Hashable {
        let type: ZephyrTileType
        let value: Int
    }

    private func buildTileIndex(_ tiles: [ZephyrTile]) -> [TileKey: [Int]] {
        var index: [TileKey: [Int]] = [:]
        for (idx, tile) in tiles.enumerated() {
            let key = TileKey(type: tile.type, value: tile.value)
            index[key, default: []].append(idx)
        }
        return index
    }

    // MARK: - Public API

    func detectCombinations(in hand: [ZephyrTile], with newTile: ZephyrTile) -> [TileCombination] {
        let combinedTiles = hand + [newTile]
        let tileIndex = buildTileIndex(combinedTiles)

        var combinations: [TileCombination] = []
        var processedKeys = Set<String>()

        // Detect all combination types using optimized algorithms
        combinations.append(contentsOf: detectQuads(tileIndex: tileIndex, tiles: combinedTiles, processed: &processedKeys))
        combinations.append(contentsOf: detectTriplets(tileIndex: tileIndex, tiles: combinedTiles, processed: &processedKeys))
        combinations.append(contentsOf: detectSequences(tiles: combinedTiles, processed: &processedKeys))
        combinations.append(contentsOf: detectPairs(tileIndex: tileIndex, tiles: combinedTiles, processed: &processedKeys))

        return combinations
    }

    func canSelectTile(_ tile: ZephyrTile, with hand: [ZephyrTile], maxHandSize: Int) -> Bool {
        if hand.count < maxHandSize {
            return true
        }

        // Can only select if it creates at least one valid combination
        let combinations = detectCombinations(in: hand, with: tile)
        return !combinations.isEmpty
    }

    func removeCombination(_ combination: TileCombination, from hand: [ZephyrTile]) -> [ZephyrTile] {
        var updatedHand = hand
        let remainingCombinationTiles = combination.tiles

        // Remove tiles by matching type and value
        for combinationTile in remainingCombinationTiles {
            if let idx = updatedHand.firstIndex(where: { $0.type == combinationTile.type && $0.value == combinationTile.value }) {
                updatedHand.remove(at: idx)
            }
        }

        return updatedHand
    }

    func selectOptimalCombination(from combinations: [TileCombination]) -> TileCombination? {
        return combinations.max { c1, c2 in
            if c1.tiles.count != c2.tiles.count {
                return c1.tiles.count < c2.tiles.count
            }
            return c1.pattern.priority < c2.pattern.priority
        }
    }

    // MARK: - Optimized Detection Algorithms

    /// Detect quads in O(n) time
    private func detectQuads(tileIndex: [TileKey: [Int]], tiles: [ZephyrTile], processed: inout Set<String>) -> [TileCombination] {
        var quads: [TileCombination] = []

        for (key, indices) in tileIndex where indices.count >= 4 {
            let uniqueKey = "quad_\(key.type.rawValue)_\(key.value)"
            guard !processed.contains(uniqueKey) else { continue }

            let quadTiles = Array(indices.prefix(4)).map { tiles[$0] }
            quads.append(TileCombination(pattern: .quad, tiles: quadTiles))
            processed.insert(uniqueKey)
        }

        return quads
    }

    /// Detect triplets in O(n) time
    private func detectTriplets(tileIndex: [TileKey: [Int]], tiles: [ZephyrTile], processed: inout Set<String>) -> [TileCombination] {
        var triplets: [TileCombination] = []

        for (key, indices) in tileIndex where indices.count >= 3 {
            let uniqueKey = "triplet_\(key.type.rawValue)_\(key.value)"
            guard !processed.contains(uniqueKey) else { continue }

            let tripletTiles = Array(indices.prefix(3)).map { tiles[$0] }
            triplets.append(TileCombination(pattern: .triplet, tiles: tripletTiles))
            processed.insert(uniqueKey)
        }

        return triplets
    }

    /// Detect sequences in O(n) time using sliding window
    private func detectSequences(tiles: [ZephyrTile], processed: inout Set<String>) -> [TileCombination] {
        var sequences: [TileCombination] = []

        // Group by regular tile types only
        let regularTiles = tiles.filter { $0.type.isRegular }
        let groupedByType = Dictionary(grouping: regularTiles) { $0.type }

        for (tileType, typeTiles) in groupedByType {
            // Build value frequency map
            let valueMap = Dictionary(grouping: typeTiles) { $0.value }

            // Scan for consecutive sequences
            for startValue in 1...7 {
                let sequence = [startValue, startValue + 1, startValue + 2]

                // Check if all three consecutive values exist
                guard sequence.allSatisfy({ valueMap[$0] != nil }) else { continue }

                let uniqueKey = "seq_\(tileType.rawValue)_\(startValue)"
                guard !processed.contains(uniqueKey) else { continue }

                let sequenceTiles = sequence.compactMap { valueMap[$0]?.first }
                guard sequenceTiles.count == 3 else { continue }

                sequences.append(TileCombination(pattern: .sequence, tiles: sequenceTiles))
                processed.insert(uniqueKey)
            }
        }

        return sequences
    }

    /// Detect pairs in O(n) time
    private func detectPairs(tileIndex: [TileKey: [Int]], tiles: [ZephyrTile], processed: inout Set<String>) -> [TileCombination] {
        var pairs: [TileCombination] = []

        for (key, indices) in tileIndex where indices.count >= 2 {
            let uniqueKey = "pair_\(key.type.rawValue)_\(key.value)"
            guard !processed.contains(uniqueKey) else { continue }

            let pairTiles = Array(indices.prefix(2)).map { tiles[$0] }
            pairs.append(TileCombination(pattern: .pair, tiles: pairTiles))
            processed.insert(uniqueKey)
        }

        return pairs
    }
}
