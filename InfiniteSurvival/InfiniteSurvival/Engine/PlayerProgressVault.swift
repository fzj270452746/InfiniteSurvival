//
//  PlayerProgressVault.swift
//  InfiniteSurvival
//
//  Coins and permanent upgrades (max HP/Food/Stamina).
//

import Foundation

enum ProgressAttribute {
    case health
    case food
    case stamina
}

final class PlayerProgressVault {
    static let shared = PlayerProgressVault()
    private init() {}

    // MARK: - Storage Keys
    private let kCoins = "is_progress_coins"
    private let kHealthLevel = "is_progress_health_level"
    private let kFoodLevel = "is_progress_food_level"
    private let kStaminaLevel = "is_progress_stamina_level"

    // MARK: - Public State
    var coins: Int {
        get { UserDefaults.standard.integer(forKey: kCoins) }
        set { UserDefaults.standard.set(newValue, forKey: kCoins) }
    }

    var healthLevel: Int {
        get { UserDefaults.standard.integer(forKey: kHealthLevel) }
        set { UserDefaults.standard.set(newValue, forKey: kHealthLevel) }
    }

    var foodLevel: Int {
        get { UserDefaults.standard.integer(forKey: kFoodLevel) }
        set { UserDefaults.standard.set(newValue, forKey: kFoodLevel) }
    }

    var staminaLevel: Int {
        get { UserDefaults.standard.integer(forKey: kStaminaLevel) }
        set { UserDefaults.standard.set(newValue, forKey: kStaminaLevel) }
    }

    // MARK: - Bonuses (each level = +1 cap)
    var healthBonus: Int { healthLevel }
    var foodBonus: Int { foodLevel }
    var staminaBonus: Int { staminaLevel }

    // MARK: - Award coins at game end
    // Formula: coins = (score / 10) + day
    @discardableResult
    func awardCoins(forDay day: Int, score: Int) -> Int {
        let reward = max(0, score / 10 + day)
        coins += reward
        return reward
    }

    // MARK: - Upgrade costs
    private let baseCost = 50
    private let stepCost = 25
    private let maxLevel = 20

    func level(for attribute: ProgressAttribute) -> Int {
        switch attribute {
        case .health: return healthLevel
        case .food: return foodLevel
        case .stamina: return staminaLevel
        }
    }

    func cost(for attribute: ProgressAttribute) -> Int? {
        let lvl = level(for: attribute)
        guard lvl < maxLevel else { return nil }
        return baseCost + stepCost * lvl
    }

    func canUpgrade(_ attribute: ProgressAttribute) -> Bool {
        guard let cost = cost(for: attribute) else { return false }
        return coins >= cost
    }

    @discardableResult
    func performUpgrade(_ attribute: ProgressAttribute) -> Bool {
        guard let cost = cost(for: attribute), coins >= cost else { return false }
        coins -= cost
        switch attribute {
        case .health: healthLevel += 1
        case .food: foodLevel += 1
        case .stamina: staminaLevel += 1
        }
        return true
    }
}

