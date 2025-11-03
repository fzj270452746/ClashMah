//
//  AxiomGameMode.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import Foundation

enum AxiomGameMode {
    case normal
    case challenge
    
    var handSize: Int {
        switch self {
        case .normal:
            return 8
        case .challenge:
            return 10
        }
    }
    
    var handRows: Int {
        return 2
    }
    
    var handColumns: Int {
        switch self {
        case .normal:
            return 4
        case .challenge:
            return 5
        }
    }
    
    var middleDeckColumns: Int {
        return 5
    }
    
    var middleDeckRows: Int {
        return 2
    }
    
    var totalMiddleCards: Int {
        return 10  // Fixed: 2 rows × 5 columns = 10 cards
    }
}

