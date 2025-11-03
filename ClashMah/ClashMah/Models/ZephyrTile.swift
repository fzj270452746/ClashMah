//
//  ZephyrTile.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import UIKit

enum ZephyrTileType: String, CaseIterable {
    case fteyd = "fteyd"
    case vnahue = "vnahue"
    case poels = "poels"
    case oeiue = "oeiue"
    
    var isRegular: Bool {
        return self != .oeiue
    }
}

struct ZephyrTile: Hashable, Equatable {
    let type: ZephyrTileType
    let value: Int
    let identifier: String
    
    init(type: ZephyrTileType, value: Int) {
        self.type = type
        self.value = value
        self.identifier = "\(type.rawValue)_\(value)"
    }
    
    var imageName: String {
        return identifier
    }
    
    func canFormSequence(with other1: ZephyrTile, other2: ZephyrTile) -> Bool {
        guard type.isRegular else { return false }
        guard type == other1.type && type == other2.type else { return false }
        
        let values = [value, other1.value, other2.value].sorted()
        return values[0] + 1 == values[1] && values[1] + 1 == values[2]
    }
    
    func canFormPair(with other: ZephyrTile) -> Bool {
        return type == other.type && value == other.value
    }
    
    func canFormTriplet(with other1: ZephyrTile, other2: ZephyrTile) -> Bool {
        return type == other1.type && type == other2.type &&
               value == other1.value && value == other2.value
    }
    
    func canFormQuad(with other1: ZephyrTile, other2: ZephyrTile, other3: ZephyrTile) -> Bool {
        return type == other1.type && type == other2.type && type == other3.type &&
               value == other1.value && value == other2.value && value == other3.value
    }
}

