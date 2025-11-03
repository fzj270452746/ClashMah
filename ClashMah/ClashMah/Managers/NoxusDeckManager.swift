//
//  NoxusDeckManager.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import Foundation

class NoxusDeckManager {
    static let shared = NoxusDeckManager()
    
    private init() {}
    
    func generateFullDeck() -> [ZephyrTile] {
        var deck: [ZephyrTile] = []
        
        // Regular tiles: 3 types × 9 values × 4 copies
        let regularTypes: [ZephyrTileType] = [.fteyd, .vnahue, .poels]
        for type in regularTypes {
            for value in 1...9 {
                for _ in 0..<4 {
                    deck.append(ZephyrTile(type: type, value: value))
                }
            }
        }
        
        // Special tiles: 7 types × 4 copies
        for value in 1...7 {
            for _ in 0..<4 {
                deck.append(ZephyrTile(type: .oeiue, value: value))
            }
        }
        
        return deck.shuffled()
    }
    
    func dealHands(deck: inout [ZephyrTile], handSize: Int) -> ([ZephyrTile], [ZephyrTile]) {
        var playerHand: [ZephyrTile] = []
        var computerHand: [ZephyrTile] = []
        
        for _ in 0..<handSize {
            if !deck.isEmpty {
                playerHand.append(deck.removeFirst())
            }
        }
        
        for _ in 0..<handSize {
            if !deck.isEmpty {
                computerHand.append(deck.removeFirst())
            }
        }
        
        return (playerHand, computerHand)
    }
    
    func dealMiddleDeck(deck: inout [ZephyrTile], count: Int) -> [ZephyrTile] {
        var middleCards: [ZephyrTile] = []
        for _ in 0..<count {
            if !deck.isEmpty {
                middleCards.append(deck.removeFirst())
            }
        }
        return middleCards
    }
}

