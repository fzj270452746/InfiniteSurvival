//
//  PersistedScoreVault.swift
//  InfiniteSurvival
//
//  High score persistence manager
//

import Foundation

class PersistedScoreVault {

    static let sharedVault = PersistedScoreVault()

    private let storageKeyBestDay = "is_vault_best_day_record"
    private let storageKeyBestScore = "is_vault_best_score_record"
    private let storageKeyTotalGames = "is_vault_total_games_played"

    private init() {}

    var bestDaySurvived: Int {
        get { UserDefaults.standard.integer(forKey: storageKeyBestDay) }
        set { UserDefaults.standard.set(newValue, forKey: storageKeyBestDay) }
    }

    var bestScoreAchieved: Int {
        get { UserDefaults.standard.integer(forKey: storageKeyBestScore) }
        set { UserDefaults.standard.set(newValue, forKey: storageKeyBestScore) }
    }

    var totalGamesPlayed: Int {
        get { UserDefaults.standard.integer(forKey: storageKeyTotalGames) }
        set { UserDefaults.standard.set(newValue, forKey: storageKeyTotalGames) }
    }

    func submitSessionResult(daySurvived: Int, score: Int) {
        totalGamesPlayed += 1
        if daySurvived > bestDaySurvived {
            bestDaySurvived = daySurvived
        }
        if score > bestScoreAchieved {
            bestScoreAchieved = score
        }
    }
}
