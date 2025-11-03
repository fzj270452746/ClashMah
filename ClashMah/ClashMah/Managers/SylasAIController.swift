//
//  SylasAIController.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import Foundation

class SylasAIController {
    static func selectBestMove(hand: [ZephyrTile], middleDeck: [ZephyrTile], maxHandSize: Int) -> Int? {
        // Try each tile in middle deck
        var bestMove: Int?
        var bestMeldCount = 0
        
        for (index, tile) in middleDeck.enumerated() {
            // Check if can select this tile
            guard RivenMatchingEngine.canSelectTile(tile: tile, hand: hand, maxHandSize: maxHandSize) else {
                continue
            }
            
            // Count possible melds
            let melds = RivenMatchingEngine.findPossibleMelds(hand: hand, selectedTile: tile)
            
            // Prefer moves that create more melds or higher value melds
            var meldScore = melds.count
            for meld in melds {
                switch meld.type {
                case .quad:
                    meldScore += 4
                case .triplet:
                    meldScore += 3
                case .sequence:
                    meldScore += 2
                case .pair:
                    meldScore += 1
                }
            }
            
            if meldScore > bestMeldCount {
                bestMeldCount = meldScore
                bestMove = index
            }
        }
        
        return bestMove
    }
    
    static func selectBestMeld(hand: [ZephyrTile], selectedTile: ZephyrTile) -> RivenMeld? {
        let melds = RivenMatchingEngine.findPossibleMelds(hand: hand, selectedTile: selectedTile)
        
        // Prefer quads > triplets > sequences > pairs
        if let quad = melds.first(where: { $0.type == .quad }) {
            return quad
        }
        if let triplet = melds.first(where: { $0.type == .triplet }) {
            return triplet
        }
        if let sequence = melds.first(where: { $0.type == .sequence }) {
            return sequence
        }
        if let pair = melds.first(where: { $0.type == .pair }) {
            return pair
        }
        
        return melds.first
    }
}

