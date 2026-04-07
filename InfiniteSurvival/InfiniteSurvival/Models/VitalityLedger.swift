//
//  VitalityLedger.swift
//  InfiniteSurvival
//
//  Survival stats tracking model
//

import Foundation

// MARK: - Survival Statistics
class VitalityLedger {

    // MARK: - Current Values
    private(set) var currentHealth: Int
    private(set) var currentFood: Int
    private(set) var currentStamina: Int

    // MARK: - Capacity Ceilings
    private(set) var healthCeiling: Int
    private(set) var foodCeiling: Int
    private(set) var staminaCeiling: Int

    // MARK: - Progression
    private(set) var elapsedDayCount: Int = 0
    private(set) var accumulatedScore: Int = 0

    // MARK: - Constants
    private let baselineHealth: Int = 20
    private let baselineFood: Int = 10
    private let baselineStamina: Int = 10

    private let foodDecayPerTurn: Int = 2
    private let staminaDecayPerTurn: Int = 1
    private let starvationDamage: Int = 3
    private let ceilingGrowthInterval: Int = 5
    private let ceilingGrowthAmount: Int = 1

    // MARK: - Hand
    private(set) var handCapacityCeiling: Int = 20
    let initialHandVolume: Int = 5

    // MARK: - Init
    init() {
        self.healthCeiling = baselineHealth
        self.foodCeiling = baselineFood
        self.staminaCeiling = baselineStamina
        self.currentHealth = baselineHealth
        self.currentFood = baselineFood
        self.currentStamina = baselineStamina
    }

    // MARK: - Turn Consumption
    @discardableResult
    func executeEndOfTurnDecay() -> (foodLost: Int, staminaLost: Int, healthLost: Int) {
        let actualFoodLoss = min(currentFood, foodDecayPerTurn)
        currentFood -= actualFoodLoss

        let actualStaminaLoss = min(currentStamina, staminaDecayPerTurn)
        currentStamina -= actualStaminaLoss

        var healthLost = 0
        if currentFood <= 0 {
            healthLost = starvationDamage
            currentHealth = max(0, currentHealth - starvationDamage)
        }

        elapsedDayCount += 1
        accumulatedScore += 1

        if elapsedDayCount % ceilingGrowthInterval == 0 {
            healthCeiling += ceilingGrowthAmount
            foodCeiling += ceilingGrowthAmount
            staminaCeiling += ceilingGrowthAmount
        }

        return (actualFoodLoss, actualStaminaLoss, healthLost)
    }

    // MARK: - Resource Modification
    func replenishFood(_ amount: Int) {
        let effectiveAmount = currentStamina <= 0 ? amount / 2 : amount
        currentFood = min(currentFood + effectiveAmount, foodCeiling)
    }

    func replenishStamina(_ amount: Int) {
        let effectiveAmount = currentStamina <= 0 ? max(1, amount / 2) : amount
        currentStamina = min(currentStamina + effectiveAmount, staminaCeiling)
    }

    func replenishHealth(_ amount: Int) {
        currentHealth = min(currentHealth + amount, healthCeiling)
    }

    func inflictDamage(_ amount: Int) {
        currentHealth = max(0, currentHealth - amount)
    }

    // MARK: - Score
    func augmentScore(_ points: Int) {
        accumulatedScore += points
    }

    // MARK: - State Queries
    var isExpired: Bool {
        return currentHealth <= 0
    }

    var isStarving: Bool {
        return currentFood <= 0
    }

    var isExhausted: Bool {
        return currentStamina <= 0
    }

    var healthFraction: CGFloat {
        return CGFloat(currentHealth) / CGFloat(max(1, healthCeiling))
    }

    var foodFraction: CGFloat {
        return CGFloat(currentFood) / CGFloat(max(1, foodCeiling))
    }

    var staminaFraction: CGFloat {
        return CGFloat(currentStamina) / CGFloat(max(1, staminaCeiling))
    }

    // MARK: - Reset
    func resetToGenesis() {
        healthCeiling = baselineHealth
        foodCeiling = baselineFood
        staminaCeiling = baselineStamina
        currentHealth = baselineHealth
        currentFood = baselineFood
        currentStamina = baselineStamina
        elapsedDayCount = 0
        accumulatedScore = 0
    }
}
