//
//  RivenMatchingEngine.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import Foundation

enum RivenMeldType {
    case pair
    case sequence
    case triplet
    case quad
}

struct RivenMeld {
    let type: RivenMeldType
    let tiles: [ZephyrTile]
}

class RivenMatchingEngine {
    static func findPossibleMelds(hand: [ZephyrTile], selectedTile: ZephyrTile) -> [RivenMeld] {
        var melds: [RivenMeld] = []
        let combinedHand = hand + [selectedTile]
        
        // Find pairs
        let pairMelds = findPairs(in: combinedHand)
        melds.append(contentsOf: pairMelds)
        
        // Find triplets
        let tripletMelds = findTriplets(in: combinedHand)
        melds.append(contentsOf: tripletMelds)
        
        // Find quads
        let quadMelds = findQuads(in: combinedHand)
        melds.append(contentsOf: quadMelds)
        
        // Find sequences (only for regular tiles)
        let sequenceMelds = findSequences(in: combinedHand)
        melds.append(contentsOf: sequenceMelds)
        
        return melds
    }
    
    private static func findPairs(in tiles: [ZephyrTile]) -> [RivenMeld] {
        var pairs: [RivenMeld] = []
        var checked = Set<String>()
        
        for i in 0..<tiles.count {
            for j in (i+1)..<tiles.count {
                if tiles[i].canFormPair(with: tiles[j]) {
                    let key = "\(tiles[i].type.rawValue)_\(tiles[i].value)"
                    if !checked.contains(key) {
                        pairs.append(RivenMeld(type: .pair, tiles: [tiles[i], tiles[j]]))
                        checked.insert(key)
                    }
                }
            }
        }
        
        return pairs
    }
    
    private static func findTriplets(in tiles: [ZephyrTile]) -> [RivenMeld] {
        var triplets: [RivenMeld] = []
        var checked = Set<String>()
        
        for i in 0..<tiles.count {
            for j in (i+1)..<tiles.count {
                for k in (j+1)..<tiles.count {
                    if tiles[i].canFormTriplet(with: tiles[j], other2: tiles[k]) {
                        let key = "\(tiles[i].type.rawValue)_\(tiles[i].value)"
                        if !checked.contains(key) {
                            triplets.append(RivenMeld(type: .triplet, tiles: [tiles[i], tiles[j], tiles[k]]))
                            checked.insert(key)
                        }
                    }
                }
            }
        }
        
        return triplets
    }
    
    private static func findQuads(in tiles: [ZephyrTile]) -> [RivenMeld] {
        var quads: [RivenMeld] = []
        var checked = Set<String>()
        
        for i in 0..<tiles.count {
            for j in (i+1)..<tiles.count {
                for k in (j+1)..<tiles.count {
                    for l in (k+1)..<tiles.count {
                        if tiles[i].canFormQuad(with: tiles[j], other2: tiles[k], other3: tiles[l]) {
                            let key = "\(tiles[i].type.rawValue)_\(tiles[i].value)"
                            if !checked.contains(key) {
                                quads.append(RivenMeld(type: .quad, tiles: [tiles[i], tiles[j], tiles[k], tiles[l]]))
                                checked.insert(key)
                            }
                        }
                    }
                }
            }
        }
        
        return quads
    }
    
    private static func findSequences(in tiles: [ZephyrTile]) -> [RivenMeld] {
        var sequences: [RivenMeld] = []
        let regularTiles = tiles.filter { $0.type.isRegular }
        
        // Group by type
        let groupedByType = Dictionary(grouping: regularTiles) { $0.type }
        
        for (_, typeTiles) in groupedByType {
            // Get all unique values
            let valueCounts = Dictionary(grouping: typeTiles) { $0.value }
            
            // Try to find sequences
            for val1 in 1...7 {
                guard let tiles1 = valueCounts[val1], !tiles1.isEmpty else { continue }
                guard let tiles2 = valueCounts[val1 + 1], !tiles2.isEmpty else { continue }
                guard let tiles3 = valueCounts[val1 + 2], !tiles3.isEmpty else { continue }
                
                // Create a sequence with one tile from each value
                let tile1 = tiles1[0]
                let tile2 = tiles2[0]
                let tile3 = tiles3[0]
                
                sequences.append(RivenMeld(type: .sequence, tiles: [tile1, tile2, tile3]))
            }
        }
        
        return sequences
    }
    
    static func canSelectTile(tile: ZephyrTile, hand: [ZephyrTile], maxHandSize: Int) -> Bool {
        let melds = findPossibleMelds(hand: hand, selectedTile: tile)
        if melds.isEmpty && hand.count >= maxHandSize {
            return false
        }
        return true
    }
    
    static func removeMeldedTiles(from hand: [ZephyrTile], meld: RivenMeld) -> [ZephyrTile] {
        var remainingHand = hand
        var usedIndices = Set<Int>()
        
        // Match tiles by type and value, not by identity
        for meldTile in meld.tiles {
            for (index, handTile) in remainingHand.enumerated() {
                if handTile.type == meldTile.type && handTile.value == meldTile.value && !usedIndices.contains(index) {
                    usedIndices.insert(index)
                    break
                }
            }
        }
        
        // Remove tiles in reverse order to maintain indices
        for index in usedIndices.sorted(by: >) {
            remainingHand.remove(at: index)
        }
        
        return remainingHand
    }
}

