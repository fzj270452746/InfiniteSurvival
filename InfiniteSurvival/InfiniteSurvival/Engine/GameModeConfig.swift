//
//  GameModeConfig.swift
//  InfiniteSurvival
//
//  Defines play modes and tunable rules used by the engine.
//

import Foundation

enum GameMode: Equatable {
    case casual
    case normal
    case hard
    case daily(seed: Int)
}

struct DailyAffix: Equatable {
    let id: String
    let title: String
    let description: String
}

struct GameModeConfig: Equatable {
    let mode: GameMode
    let foodDecayPerTurn: Int
    let staminaDecayPerTurn: Int
    let starvationDamage: Int
    let eventIntervalDays: Int
    let scoreMultiplier: Int
    let handCapacityBonus: Int
    let dailyAffixes: [DailyAffix]

    static func forMode(_ mode: GameMode) -> GameModeConfig {
        switch mode {
        case .casual:
            return GameModeConfig(
                mode: mode,
                foodDecayPerTurn: 1,
                staminaDecayPerTurn: 0,
                starvationDamage: 1,
                eventIntervalDays: 4,
                scoreMultiplier: 1,
                handCapacityBonus: 2,
                dailyAffixes: []
            )
        case .normal:
            return GameModeConfig(
                mode: mode,
                foodDecayPerTurn: 2,
                staminaDecayPerTurn: 1,
                starvationDamage: 3,
                eventIntervalDays: 3,
                scoreMultiplier: 1,
                handCapacityBonus: 0,
                dailyAffixes: []
            )
        case .hard:
            return GameModeConfig(
                mode: mode,
                foodDecayPerTurn: 3,
                staminaDecayPerTurn: 2,
                starvationDamage: 5,
                eventIntervalDays: 2,
                scoreMultiplier: 2,
                handCapacityBonus: 0,
                dailyAffixes: []
            )
        case .daily(let seed):
            let affixes = DailyAffixFactory.affixes(forSeed: seed)
            return GameModeConfig(
                mode: mode,
                foodDecayPerTurn: 2,
                staminaDecayPerTurn: 1 + (affixes.contains(where: { $0.id == "affix_endurance_tax" }) ? 1 : 0),
                starvationDamage: 3,
                eventIntervalDays: affixes.contains(where: { $0.id == "affix_omens" }) ? 2 : 3,
                scoreMultiplier: 2,
                handCapacityBonus: affixes.contains(where: { $0.id == "affix_handroom" }) ? 2 : 0,
                dailyAffixes: affixes
            )
        }
    }
}

enum DailyAffixFactory {

    // Deterministic pseudo-random selection based on seed
    static func affixes(forSeed seed: Int) -> [DailyAffix] {
        var rng = LCG(seed: UInt64(seed))
        let pool: [DailyAffix] = [
            DailyAffix(id: "affix_chain_meal", title: "Chain Meal", description: "+1 Food on Sequences"),
            DailyAffix(id: "affix_endurance_tax", title: "Endurance Tax", description: "+1 Stamina decay per turn"),
            DailyAffix(id: "affix_handroom", title: "Handroom", description: "+2 hand size"),
            DailyAffix(id: "affix_omens", title: "Omens", description: "Events are more frequent (every 2 days)")
        ]
        // pick 3 unique affixes
        var chosen: [DailyAffix] = []
        var indices = Array(pool.indices)
        for _ in 0..<3 where !indices.isEmpty {
            let idx = Int(rng.next() % UInt64(indices.count))
            chosen.append(pool[indices.remove(at: idx)])
        }
        return chosen
    }
}

// Simple linear congruential generator for deterministic picks
private struct LCG {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}
