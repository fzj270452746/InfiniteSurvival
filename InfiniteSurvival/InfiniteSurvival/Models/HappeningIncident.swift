//
//  HappeningIncident.swift
//  InfiniteSurvival
//
//  Event system model
//

import Foundation

// MARK: - Event Types
enum IncidentCategory: String, CaseIterable {
    case beastAssault     // Wild beast attack
    case foodDiscovery    // Found food
    case staminaWell      // Energy spring
    case wanderingHealer  // Traveling healer
    case ambushTrap       // Trap encounter
    case mysticShrine     // Mysterious shrine
    case merchant         // Trade resources
    case thunderstorm     // Random discard / damage

    var displayTitle: String {
        switch self {
        case .beastAssault:    return "Beast Assault!"
        case .foodDiscovery:   return "Food Discovery"
        case .staminaWell:     return "Energy Spring"
        case .wanderingHealer: return "Wandering Healer"
        case .ambushTrap:      return "Ambush Trap!"
        case .mysticShrine:    return "Mystic Shrine"
        case .merchant:      return "Traveling Merchant"
        case .thunderstorm:  return "Thunderstorm"
        }
    }

    var narrativeCaption: String {
        switch self {
        case .beastAssault:
            return "A wild beast lunges from the shadows! Play a Triplet to fend it off!"
        case .foodDiscovery:
            return "You stumble upon a hidden cache. Play a Sequence for double food!"
        case .staminaWell:
            return "A glowing spring beckons. Play a Pair to restore energy!"
        case .wanderingHealer:
            return "A mysterious healer offers aid. Play any valid meld to heal!"
        case .ambushTrap:
            return "You triggered a trap! Play a Triplet or take damage!"
        case .mysticShrine:
            return "An ancient shrine pulses with power. Offer tiles for a blessing!"
        case .merchant:
            return "A traveling merchant offers trades. Play a Pair for a better deal!"
        case .thunderstorm:
            return "A thunderstorm rages! Play a Sequence to brace, or lose a random tile and HP."
        }
    }

    var themeIconName: String {
        switch self {
        case .beastAssault:    return "flame.fill"
        case .foodDiscovery:   return "leaf.fill"
        case .staminaWell:     return "bolt.fill"
        case .wanderingHealer: return "heart.fill"
        case .ambushTrap:      return "exclamationmark.triangle.fill"
        case .mysticShrine:    return "sparkles"
        case .merchant:        return "bag"
        case .thunderstorm:    return "cloud.bolt.rain.fill"
        }
    }

    var accentHexColor: String {
        switch self {
        case .beastAssault:    return "#FF4444"
        case .foodDiscovery:   return "#4CAF50"
        case .staminaWell:     return "#2196F3"
        case .wanderingHealer: return "#E91E63"
        case .ambushTrap:      return "#FF9800"
        case .mysticShrine:    return "#9C27B0"
        case .merchant:        return "#795548"
        case .thunderstorm:    return "#607D8B"
        }
    }
}

// MARK: - Event Instance
struct HappeningIncident {
    let category: IncidentCategory
    let requiredMeldKind: MeldPatternKind?

    // Success rewards
    let foodBonusOnSuccess: Int
    let staminaBonusOnSuccess: Int
    let healthBonusOnSuccess: Int

    // Failure penalties
    let healthPenaltyOnFail: Int
    let foodPenaltyOnFail: Int
    let staminaPenaltyOnFail: Int

    var isHostile: Bool {
        return category == .beastAssault || category == .ambushTrap
    }
}

// MARK: - Event Generator
struct IncidentForgeFactory {

    static func fabricateRandomIncident(forDay dayIndex: Int, modeConfig: GameModeConfig) -> HappeningIncident {
        let scaleFactor = 1.0 + Double(dayIndex) / 20.0
        var allCategories = IncidentCategory.allCases
        // Daily affixes can bias or filter incidents
        if modeConfig.dailyAffixes.contains(where: { $0.id == "affix_omens" }) {
            // Increase odds of hostile weather and beasts
            allCategories += [.beastAssault, .thunderstorm]
        }
        let chosenCategory = allCategories[Int.random(in: 0..<allCategories.count)]

        switch chosenCategory {
        case .beastAssault:
            return HappeningIncident(
                category: .beastAssault,
                requiredMeldKind: .triplet,
                foodBonusOnSuccess: 0,
                staminaBonusOnSuccess: 2,
                healthBonusOnSuccess: 0,
                healthPenaltyOnFail: Int(Double(2) * scaleFactor),
                foodPenaltyOnFail: 0,
                staminaPenaltyOnFail: 1
            )

        case .foodDiscovery:
            return HappeningIncident(
                category: .foodDiscovery,
                requiredMeldKind: .sequence,
                foodBonusOnSuccess: Int(Double(6) * scaleFactor),
                staminaBonusOnSuccess: 0,
                healthBonusOnSuccess: 0,
                healthPenaltyOnFail: 0,
                foodPenaltyOnFail: 0,
                staminaPenaltyOnFail: 0
            )

        case .staminaWell:
            return HappeningIncident(
                category: .staminaWell,
                requiredMeldKind: .pair,
                foodBonusOnSuccess: 0,
                staminaBonusOnSuccess: Int(Double(5) * scaleFactor),
                healthBonusOnSuccess: 0,
                healthPenaltyOnFail: 0,
                foodPenaltyOnFail: 0,
                staminaPenaltyOnFail: 0
            )

        case .wanderingHealer:
            return HappeningIncident(
                category: .wanderingHealer,
                requiredMeldKind: nil,
                foodBonusOnSuccess: 2,
                staminaBonusOnSuccess: 2,
                healthBonusOnSuccess: Int(Double(3) * scaleFactor),
                healthPenaltyOnFail: 0,
                foodPenaltyOnFail: 0,
                staminaPenaltyOnFail: 0
            )

        case .ambushTrap:
            return HappeningIncident(
                category: .ambushTrap,
                requiredMeldKind: .triplet,
                foodBonusOnSuccess: 3,
                staminaBonusOnSuccess: 3,
                healthBonusOnSuccess: 0,
                healthPenaltyOnFail: Int(Double(3) * scaleFactor),
                foodPenaltyOnFail: 1,
                staminaPenaltyOnFail: 2
            )

        case .mysticShrine:
            return HappeningIncident(
                category: .mysticShrine,
                requiredMeldKind: nil,
                foodBonusOnSuccess: 3,
                staminaBonusOnSuccess: 3,
                healthBonusOnSuccess: 3,
                healthPenaltyOnFail: 0,
                foodPenaltyOnFail: 0,
                staminaPenaltyOnFail: 0
            )

        case .merchant:
            return HappeningIncident(
                category: .merchant,
                requiredMeldKind: .pair,
                foodBonusOnSuccess: 4,
                staminaBonusOnSuccess: -1, // 以体力换食物
                healthBonusOnSuccess: 1,
                healthPenaltyOnFail: 0,
                foodPenaltyOnFail: 0,
                staminaPenaltyOnFail: 1
            )

        case .thunderstorm:
            return HappeningIncident(
                category: .thunderstorm,
                requiredMeldKind: .sequence,
                foodBonusOnSuccess: 0,
                staminaBonusOnSuccess: 1,
                healthBonusOnSuccess: 0,
                healthPenaltyOnFail: Int(Double(2) * scaleFactor),
                foodPenaltyOnFail: 0,
                staminaPenaltyOnFail: 0
            )
        }
    }
}
