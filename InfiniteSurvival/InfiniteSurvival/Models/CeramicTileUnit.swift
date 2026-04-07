//
//  CeramicTileUnit.swift
//  InfiniteSurvival
//
//  Mahjong tile data model
//

import Foundation

// MARK: - Tile Suit
enum VesselSuitKind: String, CaseIterable, Codable {
    case bamboo    // 条 - Stamina
    case character // 万 - Food
    case circle    // 筒 - Attack
    case special   // 字牌 - Special

    var assetPrefix: String {
        switch self {
        case .bamboo:    return "is_bamboo"
        case .character: return "is_character"
        case .circle:    return "is_circle"
        case .special:   return "is_special"
        }
    }

    var displayEmblem: String {
        switch self {
        case .bamboo:    return "⚡"
        case .character: return "🍗"
        case .circle:    return "⛓"
        case .special:   return "✨"
        }
    }
}

// MARK: - Tile Model
struct CeramicTileUnit: Equatable, Hashable, Codable {
    let vesselSuit: VesselSuitKind
    let numericRank: Int // 1-9 for normal suits, 1-7 for special

    var assetMoniker: String {
        return "\(vesselSuit.assetPrefix)-\(numericRank)"
    }

    static func == (lhs: CeramicTileUnit, rhs: CeramicTileUnit) -> Bool {
        return lhs.vesselSuit == rhs.vesselSuit && lhs.numericRank == rhs.numericRank
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(vesselSuit)
        hasher.combine(numericRank)
    }
}

// MARK: - Pattern Recognition
enum MeldPatternKind: String {
    case pair       // 对子 - 2 same tiles
    case sequence   // 顺子 - 3 consecutive tiles of same suit
    case triplet    // 刻子 - 3 same tiles
    case quartet    // 杠 - 4 same tiles
    case winningHand // 胡牌
    case debris     // 杂牌 - no pattern

    var rewardCoefficient: Int {
        switch self {
        case .pair:        return 2
        case .sequence:    return 3
        case .triplet:     return 5
        case .quartet:     return 0  // heals HP instead
        case .winningHand: return 10
        case .debris:      return 0
        }
    }

    var quartetHealAmount: Int { return 5 }

    var displayTitle: String {
        switch self {
        case .pair:        return "Pair"
        case .sequence:    return "Sequence"
        case .triplet:     return "Triplet"
        case .quartet:     return "Quad"
        case .winningHand: return "Winning Hand!"
        case .debris:      return "No Match"
        }
    }

    var displayCaption: String {
        switch self {
        case .pair:        return "+2 Resources"
        case .sequence:    return "+3 Resources"
        case .triplet:     return "+5 Resources"
        case .quartet:     return "Heal +5 HP"
        case .winningHand: return "+10 Resources & Heal"
        case .debris:      return "Wasted..."
        }
    }
}

// MARK: - Pattern Evaluation Result
struct MeldEvaluationOutcome {
    let patternKind: MeldPatternKind
    let involvedTiles: [CeramicTileUnit]
    let foodYield: Int
    let staminaYield: Int
    let healthYield: Int
    let attackPotency: Int
}
