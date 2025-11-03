//
//  VexilGameState.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import Foundation

enum VexilPlayerType {
    case human
    case computer
}

struct VexilGameState {
    var playerHand: [ZephyrTile]
    var computerHand: [ZephyrTile]
    var middleDeck: [ZephyrTile]
    var remainingDeck: [ZephyrTile]
    var currentPlayer: VexilPlayerType
    var gameMode: AxiomGameMode
    var challengeRound: Int
    var challengePlayerScore: Int
    var challengeComputerScore: Int
    
    init(gameMode: AxiomGameMode) {
        self.gameMode = gameMode
        self.playerHand = []
        self.computerHand = []
        self.middleDeck = []
        self.remainingDeck = []
        self.currentPlayer = .human
        self.challengeRound = 0
        self.challengeComputerScore = 0
        self.challengePlayerScore = 0
    }
    
    var isGameOver: Bool {
        return playerHand.isEmpty || computerHand.isEmpty
    }
    
    var winner: VexilPlayerType? {
        if playerHand.isEmpty {
            return .human
        } else if computerHand.isEmpty {
            return .computer
        }
        return nil
    }
}

