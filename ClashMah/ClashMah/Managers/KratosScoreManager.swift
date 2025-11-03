//
//  KratosScoreManager.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import Foundation

class KratosScoreManager {
    private static let normalModeKey = "normalModeWins"
    private static let challengeModeKey = "challengeModeWins"
    private static let challengeModeLossesKey = "challengeModeLosses"
    
    static func incrementNormalModeWin() {
        let current = UserDefaults.standard.integer(forKey: normalModeKey)
        UserDefaults.standard.set(current + 1, forKey: normalModeKey)
    }
    
    static func incrementChallengeModeWin() {
        let current = UserDefaults.standard.integer(forKey: challengeModeKey)
        UserDefaults.standard.set(current + 1, forKey: challengeModeKey)
    }
    
    static func incrementChallengeModeLoss() {
        let current = UserDefaults.standard.integer(forKey: challengeModeLossesKey)
        UserDefaults.standard.set(current + 1, forKey: challengeModeLossesKey)
    }
    
    static func getNormalModeWins() -> Int {
        return UserDefaults.standard.integer(forKey: normalModeKey)
    }
    
    static func getChallengeModeWins() -> Int {
        return UserDefaults.standard.integer(forKey: challengeModeKey)
    }
    
    static func getChallengeModeLosses() -> Int {
        return UserDefaults.standard.integer(forKey: challengeModeLossesKey)
    }
    
    static func saveFeedback(_ feedback: String) {
        let key = "feedback_\(Date().timeIntervalSince1970)"
        UserDefaults.standard.set(feedback, forKey: key)
    }
}

