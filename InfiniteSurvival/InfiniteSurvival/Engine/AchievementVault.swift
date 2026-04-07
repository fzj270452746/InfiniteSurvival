//
//  AchievementVault.swift
//  InfiniteSurvival
//
//  Achievement persistence and unlock-check engine
//

import Foundation

class AchievementVault {

    static let shared = AchievementVault()

    // MARK: - Storage Keys
    private let keyUnlocked    = "is_achievement_unlocked_ids"
    private let keyTotalMelds  = "is_achievement_total_melds"
    private let keyTotalDraws  = "is_achievement_total_draws"
    private let keyTotalEventWins = "is_achievement_total_event_wins"
    private let keyTotalDiscards  = "is_achievement_total_discards"

    private init() {}

    // MARK: - Unlocked Set
    var unlockedIDs: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: keyUnlocked) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: keyUnlocked)
        }
    }

    var unlockedCount: Int { unlockedIDs.count }
    var totalCount: Int { AchievementMedal.fullCatalog.count }

    func isUnlocked(_ id: String) -> Bool {
        unlockedIDs.contains(id)
    }

    // MARK: - Cumulative Counters
    var totalMeldsPlayed: Int {
        get { UserDefaults.standard.integer(forKey: keyTotalMelds) }
        set { UserDefaults.standard.set(newValue, forKey: keyTotalMelds) }
    }

    var totalDraws: Int {
        get { UserDefaults.standard.integer(forKey: keyTotalDraws) }
        set { UserDefaults.standard.set(newValue, forKey: keyTotalDraws) }
    }

    var totalEventWins: Int {
        get { UserDefaults.standard.integer(forKey: keyTotalEventWins) }
        set { UserDefaults.standard.set(newValue, forKey: keyTotalEventWins) }
    }

    var totalDiscards: Int {
        get { UserDefaults.standard.integer(forKey: keyTotalDiscards) }
        set { UserDefaults.standard.set(newValue, forKey: keyTotalDiscards) }
    }

    // MARK: - Record + Check

    /// Called after a successful meld. Returns newly unlocked medals.
    func recordMeld(pattern: MeldPatternKind, dayIndex: Int) -> [AchievementMedal] {
        totalMeldsPlayed += 1
        var candidates: [String] = []

        // Pattern-specific
        switch pattern {
        case .pair:        candidates.append("meld_pair")
        case .sequence:    candidates.append("meld_sequence")
        case .triplet:     candidates.append("meld_triplet")
        case .quartet:     candidates.append("meld_quartet")
        case .winningHand: candidates.append("meld_winning")
        case .debris:      break
        }

        // Meld count milestones
        if totalMeldsPlayed >= 10  { candidates.append("meld_10") }
        if totalMeldsPlayed >= 50  { candidates.append("meld_50") }
        if totalMeldsPlayed >= 100 { candidates.append("meld_100") }

        // Quick Start: triplet or better on day 0 (before first end-turn)
        if dayIndex == 0 && (pattern == .triplet || pattern == .quartet || pattern == .winningHand) {
            candidates.append("day1_meld")
        }

        return unlock(candidates)
    }

    /// Called after drawing a tile. Returns newly unlocked medals.
    func recordDraw() -> [AchievementMedal] {
        totalDraws += 1
        var candidates: [String] = []
        if totalDraws >= 50  { candidates.append("draw_50") }
        if totalDraws >= 200 { candidates.append("draw_200") }
        return unlock(candidates)
    }

    /// Called after winning an event. Returns newly unlocked medals.
    func recordEventWin(category: IncidentCategory) -> [AchievementMedal] {
        totalEventWins += 1
        var candidates: [String] = []

        if totalEventWins >= 1  { candidates.append("event_win_1") }
        if totalEventWins >= 10 { candidates.append("event_win_10") }

        switch category {
        case .beastAssault: candidates.append("event_beast")
        case .mysticShrine: candidates.append("event_shrine")
        default: break
        }

        return unlock(candidates)
    }

    /// Called after discarding a tile. Returns newly unlocked medals.
    func recordDiscard() -> [AchievementMedal] {
        totalDiscards += 1
        var candidates: [String] = []
        if totalDiscards >= 20 { candidates.append("discard_20") }
        return unlock(candidates)
    }

    /// Called at end-of-turn. Returns newly unlocked medals.
    func recordTurnEnd(dayIndex: Int, score: Int, isStarving: Bool, healthFull: Bool) -> [AchievementMedal] {
        var candidates: [String] = []

        // Survival milestones
        if dayIndex >= 1  { candidates.append("survive_1") }
        if dayIndex >= 5  { candidates.append("survive_5") }
        if dayIndex >= 10 { candidates.append("survive_10") }
        if dayIndex >= 20 { candidates.append("survive_20") }
        if dayIndex >= 50 { candidates.append("survive_50") }

        // Score milestones
        if score >= 100  { candidates.append("score_100") }
        if score >= 500  { candidates.append("score_500") }
        if score >= 1000 { candidates.append("score_1000") }

        // Resource-based
        if healthFull { candidates.append("health_full") }
        if isStarving { candidates.append("food_zero") }

        return unlock(candidates)
    }

    /// Called when a game session ends. Returns newly unlocked medals.
    func recordGameEnd() -> [AchievementMedal] {
        let totalGames = PersistedScoreVault.sharedVault.totalGamesPlayed
        var candidates: [String] = []
        if totalGames >= 5  { candidates.append("games_5") }
        if totalGames >= 20 { candidates.append("games_20") }
        return unlock(candidates)
    }

    // MARK: - Unlock Helper

    private func unlock(_ candidateIDs: [String]) -> [AchievementMedal] {
        var current = unlockedIDs
        var newlyUnlocked: [AchievementMedal] = []

        for id in candidateIDs {
            if !current.contains(id), let medal = AchievementMedal.medal(forID: id) {
                current.insert(id)
                newlyUnlocked.append(medal)
            }
        }

        if !newlyUnlocked.isEmpty {
            unlockedIDs = current
        }
        return newlyUnlocked
    }
}
