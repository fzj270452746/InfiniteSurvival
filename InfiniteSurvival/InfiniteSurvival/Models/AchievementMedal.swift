//
//  AchievementMedal.swift
//  InfiniteSurvival
//
//  Achievement data model and full catalog
//

import Foundation

// MARK: - Category
enum AchievementCategory: String, CaseIterable {
    case survival = "Survival"
    case mastery  = "Mastery"
    case combat   = "Combat"
    case resource = "Resource"
    case special  = "Special"
}

// MARK: - Medal
struct AchievementMedal {
    let id: String
    let icon: String
    let title: String
    let caption: String
    let category: AchievementCategory
}

// MARK: - Full Catalog
extension AchievementMedal {

    static let fullCatalog: [AchievementMedal] = [
        // --- Survival ---
        AchievementMedal(id: "survive_1",   icon: "🌅", title: "First Dawn",        caption: "Survive 1 day",                   category: .survival),
        AchievementMedal(id: "survive_5",   icon: "🏕", title: "Campsite",           caption: "Survive 5 days",                  category: .survival),
        AchievementMedal(id: "survive_10",  icon: "🏠", title: "Shelter Built",      caption: "Survive 10 days",                 category: .survival),
        AchievementMedal(id: "survive_20",  icon: "🏰", title: "Fortress",           caption: "Survive 20 days",                 category: .survival),
        AchievementMedal(id: "survive_50",  icon: "👑", title: "Eternal Survivor",   caption: "Survive 50 days",                 category: .survival),

        // --- Mastery (Score) ---
        AchievementMedal(id: "score_100",   icon: "⭐",  title: "Rising Star",       caption: "Reach 100 score",                 category: .mastery),
        AchievementMedal(id: "score_500",   icon: "🌟", title: "Shining Bright",     caption: "Reach 500 score",                 category: .mastery),
        AchievementMedal(id: "score_1000",  icon: "💫", title: "Legendary",          caption: "Reach 1000 score",                category: .mastery),

        // --- Mastery (Meld Types) ---
        AchievementMedal(id: "meld_pair",     icon: "🎴", title: "First Match",      caption: "Play your first Pair",            category: .mastery),
        AchievementMedal(id: "meld_sequence", icon: "📶", title: "Straight Line",    caption: "Play your first Sequence",        category: .mastery),
        AchievementMedal(id: "meld_triplet",  icon: "🔱", title: "Triple Threat",    caption: "Play your first Triplet",         category: .mastery),
        AchievementMedal(id: "meld_quartet",  icon: "💎", title: "Quad Force",       caption: "Play your first Quartet",         category: .mastery),
        AchievementMedal(id: "meld_winning",  icon: "🀄", title: "Mahjong Master",   caption: "Play a Winning Hand",             category: .mastery),

        // --- Mastery (Meld Count) ---
        AchievementMedal(id: "meld_10",   icon: "🃏", title: "Card Shark",          caption: "Play 10 melds total",             category: .mastery),
        AchievementMedal(id: "meld_50",   icon: "🎯", title: "Meld Expert",         caption: "Play 50 melds total",             category: .mastery),
        AchievementMedal(id: "meld_100",  icon: "🏅", title: "Meld Legend",         caption: "Play 100 melds total",            category: .mastery),

        // --- Combat (Events) ---
        AchievementMedal(id: "event_win_1",  icon: "🛡", title: "First Defense",     caption: "Win your first event",            category: .combat),
        AchievementMedal(id: "event_win_10", icon: "⚔️", title: "Battle Hardened",   caption: "Win 10 events",                   category: .combat),
        AchievementMedal(id: "event_beast",  icon: "🐉", title: "Beast Slayer",      caption: "Defeat a Beast Assault",          category: .combat),
        AchievementMedal(id: "event_shrine", icon: "🔮", title: "Mystic Touched",    caption: "Complete a Mystic Shrine",        category: .combat),

        // --- Resource ---
        AchievementMedal(id: "draw_50",      icon: "🎲", title: "Tile Collector",    caption: "Draw 50 tiles total",             category: .resource),
        AchievementMedal(id: "draw_200",     icon: "🗃", title: "Hoarder",           caption: "Draw 200 tiles total",            category: .resource),
        AchievementMedal(id: "health_full",  icon: "💖", title: "Full Vitality",     caption: "Restore health to maximum",       category: .resource),
        AchievementMedal(id: "food_zero",    icon: "💀", title: "Starvation Survivor", caption: "Survive a turn while starving", category: .resource),
        AchievementMedal(id: "discard_20",   icon: "🗑", title: "Wasteful",          caption: "Discard 20 tiles total",          category: .resource),

        // --- Special ---
        AchievementMedal(id: "games_5",    icon: "🎮", title: "Dedicated",           caption: "Play 5 games",                    category: .special),
        AchievementMedal(id: "games_20",   icon: "🔥", title: "Addicted",            caption: "Play 20 games",                   category: .special),
        AchievementMedal(id: "day1_meld",  icon: "⚡", title: "Quick Start",         caption: "Play a Triplet or better on Day 1", category: .special),
    ]

    static func medal(forID id: String) -> AchievementMedal? {
        fullCatalog.first { $0.id == id }
    }
}
