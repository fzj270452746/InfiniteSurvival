//
//  OrchestrationEngine.swift
//  InfiniteSurvival
//
//  Core game logic engine
//

import Foundation

// MARK: - Game Phase
enum SessionPhaseKind {
    case drawingTile
    case selectingMeld
    case resolvingEffect
    case eventEncounter
    case turnEnding
    case defeated
}

// MARK: - Engine Delegate
protocol OrchestrationEngineDelegate: AnyObject {
    func engineDidRefreshVitals(_ engine: OrchestrationEngine)
    func engineDidDealHandTiles(_ engine: OrchestrationEngine, tiles: [CeramicTileUnit])
    func engineDidDrawTile(_ engine: OrchestrationEngine, tile: CeramicTileUnit)
    func engineDidEvaluateMeld(_ engine: OrchestrationEngine, outcome: MeldEvaluationOutcome)
    func engineDidTriggerIncident(_ engine: OrchestrationEngine, incident: HappeningIncident)
    func engineDidResolveIncident(_ engine: OrchestrationEngine, incident: HappeningIncident, wasSuccessful: Bool)
    func engineDidAdvanceTurn(_ engine: OrchestrationEngine, dayIndex: Int, decayInfo: (foodLost: Int, staminaLost: Int, healthLost: Int))
    func engineDidReachDefeat(_ engine: OrchestrationEngine, finalDay: Int, finalScore: Int)
    func engineDidNotifyMessage(_ engine: OrchestrationEngine, title: String, body: String)
    func engineDidUnlockAchievements(_ engine: OrchestrationEngine, medals: [AchievementMedal])
}

// MARK: - Core Engine
class OrchestrationEngine {

    // MARK: - Properties
    weak var delegate: OrchestrationEngineDelegate?

    let vitalityLedger = VitalityLedger()
    private(set) var currentPhase: SessionPhaseKind = .drawingTile
    private(set) var handPalette: [CeramicTileUnit] = []
    private(set) var tilePondReservoir: [CeramicTileUnit] = []
    private(set) var pendingIncident: HappeningIncident?

    private var eventTriggerInterval: Int = 3
    private var modeConfig: GameModeConfig = .forMode(.normal)
    private var currentMode: GameMode = .normal

    // MARK: - Tile Pool Construction
    private func constructTilePond() -> [CeramicTileUnit] {
        var pondTiles: [CeramicTileUnit] = []

        let standardSuits: [VesselSuitKind] = [.bamboo, .character, .circle]
        for suit in standardSuits {
            for rank in 1...9 {
                // 4 copies of each tile
                for _ in 0..<4 {
                    pondTiles.append(CeramicTileUnit(vesselSuit: suit, numericRank: rank))
                }
            }
        }

        // Special tiles: 7 types, 4 copies each
        for rank in 1...7 {
            for _ in 0..<4 {
                pondTiles.append(CeramicTileUnit(vesselSuit: .special, numericRank: rank))
            }
        }

        return pondTiles.shuffled()
    }

    // MARK: - Game Start
    func commenceNewSession(mode: GameMode = .normal) {
        currentMode = mode
        modeConfig = GameModeConfig.forMode(mode)
        vitalityLedger.resetToGenesis()
        vitalityLedger.applyConfig(modeConfig)
        tilePondReservoir = constructTilePond()
        handPalette.removeAll()
        pendingIncident = nil
        currentPhase = .drawingTile
        eventTriggerInterval = modeConfig.eventIntervalDays

        // Deal initial hand
        var initialHand: [CeramicTileUnit] = []
        for _ in 0..<vitalityLedger.initialHandVolume {
            if let drawnTile = extractTileFromPond() {
                initialHand.append(drawnTile)
            }
        }
        handPalette = initialHand
        sortHandPalette()

        delegate?.engineDidDealHandTiles(self, tiles: handPalette)
        delegate?.engineDidRefreshVitals(self)
    }

    // MARK: - Draw Tile
    func performTileDraw() {
        guard currentPhase == .drawingTile else { return }
        guard handPalette.count < vitalityLedger.handCapacityCeiling else {
            delegate?.engineDidNotifyMessage(self, title: "Hand Full", body: "Discard tiles before drawing more.")
            return
        }

        if let drawnTile = extractTileFromPond() {
            handPalette.append(drawnTile)
            sortHandPalette()
            delegate?.engineDidDrawTile(self, tile: drawnTile)
            emitAchievements(AchievementVault.shared.recordDraw())
            currentPhase = .selectingMeld
        } else {
            // Reshuffle discard pile
            tilePondReservoir = constructTilePond()
            if let drawnTile = extractTileFromPond() {
                handPalette.append(drawnTile)
                sortHandPalette()
                delegate?.engineDidDrawTile(self, tile: drawnTile)
                emitAchievements(AchievementVault.shared.recordDraw())
                currentPhase = .selectingMeld
            }
        }
    }

    private func extractTileFromPond() -> CeramicTileUnit? {
        guard !tilePondReservoir.isEmpty else { return nil }
        return tilePondReservoir.removeFirst()
    }

    // MARK: - Sort Hand
    private func sortHandPalette() {
        handPalette.sort { lhs, rhs in
            if lhs.vesselSuit.rawValue != rhs.vesselSuit.rawValue {
                return lhs.vesselSuit.rawValue < rhs.vesselSuit.rawValue
            }
            return lhs.numericRank < rhs.numericRank
        }
    }

    // MARK: - Meld Evaluation
    func evaluateSelectedTiles(_ selectedIndices: [Int]) -> MeldEvaluationOutcome? {
        guard currentPhase == .selectingMeld || currentPhase == .drawingTile || currentPhase == .resolvingEffect else { return nil }

        let validIndices = selectedIndices.filter { $0 >= 0 && $0 < handPalette.count }
        guard validIndices.count >= 2 else { return nil }

        let selectedTiles = validIndices.map { handPalette[$0] }
        let patternKind = recognizeMeldPattern(selectedTiles)

        guard patternKind != .debris else {
            return MeldEvaluationOutcome(
                patternKind: .debris,
                involvedTiles: selectedTiles,
                foodYield: 0, staminaYield: 0, healthYield: 0, attackPotency: 0
            )
        }

        let outcome = computeRewards(forPattern: patternKind, withTiles: selectedTiles)

        // Remove used tiles from hand (reverse sort to maintain indices)
        for idx in validIndices.sorted().reversed() {
            handPalette.remove(at: idx)
        }

        applyMeldRewards(outcome)
        currentPhase = .drawingTile

        delegate?.engineDidEvaluateMeld(self, outcome: outcome)
        delegate?.engineDidRefreshVitals(self)
        emitAchievements(AchievementVault.shared.recordMeld(pattern: patternKind, dayIndex: vitalityLedger.elapsedDayCount))

        return outcome
    }

    // MARK: - Pattern Recognition
    func recognizeMeldPattern(_ tiles: [CeramicTileUnit]) -> MeldPatternKind {
        let count = tiles.count

        if count == 2 {
            if tiles[0] == tiles[1] {
                return .pair
            }
        }

        if count == 3 {
            // Check triplet
            if tiles[0] == tiles[1] && tiles[1] == tiles[2] {
                return .triplet
            }
            // Check sequence (same suit, consecutive ranks)
            if tiles[0].vesselSuit == tiles[1].vesselSuit &&
               tiles[1].vesselSuit == tiles[2].vesselSuit &&
               tiles[0].vesselSuit != .special {
                let sortedRanks = tiles.map { $0.numericRank }.sorted()
                if sortedRanks[1] == sortedRanks[0] + 1 && sortedRanks[2] == sortedRanks[1] + 1 {
                    return .sequence
                }
            }
        }

        if count == 4 {
            if tiles[0] == tiles[1] && tiles[1] == tiles[2] && tiles[2] == tiles[3] {
                return .quartet
            }
        }

        // Check for winning hand (simplified: 3 melds + 1 pair from 14 tiles or suitable combos)
        if count >= 5 {
            if attemptWinningHandCheck(tiles) {
                return .winningHand
            }
        }

        return .debris
    }

    private func attemptWinningHandCheck(_ tiles: [CeramicTileUnit]) -> Bool {
        // Simplified winning hand: must have at least 1 pair + rest form valid melds
        // Group tiles by suit and rank
        var countMap: [CeramicTileUnit: Int] = [:]
        for tile in tiles {
            countMap[tile, default: 0] += 1
        }

        // Try each possible pair
        for (tile, count) in countMap where count >= 2 {
            var remainingMap = countMap
            remainingMap[tile]! -= 2
            if remainingMap[tile] == 0 { remainingMap.removeValue(forKey: tile) }

            if canFormCompleteMelds(from: remainingMap) {
                return true
            }
        }
        return false
    }

    private func canFormCompleteMelds(from tileMap: [CeramicTileUnit: Int]) -> Bool {
        var workingMap = tileMap

        // Remove all zero entries
        workingMap = workingMap.filter { $0.value > 0 }

        if workingMap.isEmpty { return true }

        // Pick the first tile and try to form melds with it
        guard let firstTile = workingMap.keys.sorted(by: {
            if $0.vesselSuit.rawValue != $1.vesselSuit.rawValue {
                return $0.vesselSuit.rawValue < $1.vesselSuit.rawValue
            }
            return $0.numericRank < $1.numericRank
        }).first else { return true }

        // Try triplet
        if (workingMap[firstTile] ?? 0) >= 3 {
            var afterTriplet = workingMap
            afterTriplet[firstTile]! -= 3
            if afterTriplet[firstTile] == 0 { afterTriplet.removeValue(forKey: firstTile) }
            if canFormCompleteMelds(from: afterTriplet) { return true }
        }

        // Try sequence (only for non-special suits)
        if firstTile.vesselSuit != .special && firstTile.numericRank <= 7 {
            let second = CeramicTileUnit(vesselSuit: firstTile.vesselSuit, numericRank: firstTile.numericRank + 1)
            let third = CeramicTileUnit(vesselSuit: firstTile.vesselSuit, numericRank: firstTile.numericRank + 2)

            if (workingMap[second] ?? 0) >= 1 && (workingMap[third] ?? 0) >= 1 {
                var afterSequence = workingMap
                afterSequence[firstTile]! -= 1
                afterSequence[second]! -= 1
                afterSequence[third]! -= 1
                if afterSequence[firstTile] == 0 { afterSequence.removeValue(forKey: firstTile) }
                if afterSequence[second] == 0 { afterSequence.removeValue(forKey: second) }
                if afterSequence[third] == 0 { afterSequence.removeValue(forKey: third) }
                if canFormCompleteMelds(from: afterSequence) { return true }
            }
        }

        return false
    }

    // MARK: - Reward Computation
    private func computeRewards(forPattern pattern: MeldPatternKind, withTiles tiles: [CeramicTileUnit]) -> MeldEvaluationOutcome {
        var foodYield = 0
        var staminaYield = 0
        var healthYield = 0
        var attackPotency = 0

        let coefficient = pattern.rewardCoefficient

        switch pattern {
        case .pair, .sequence, .triplet:
            // Rewards based on tile suit
            for tile in tiles {
                switch tile.vesselSuit {
                case .character: foodYield += coefficient
                case .bamboo:    staminaYield += coefficient
                case .circle:    attackPotency += coefficient
                case .special:
                    foodYield += 1
                    staminaYield += 1
                }
            }
            // Normalize: give mixed rewards for non-food/stamina suits
            if foodYield == 0 { foodYield = coefficient / 2 }
            if staminaYield == 0 { staminaYield = coefficient / 2 }

        case .quartet:
            healthYield = pattern.quartetHealAmount

        case .winningHand:
            foodYield = 10
            staminaYield = 10
            healthYield = 5

        case .debris:
            break
        }

        return MeldEvaluationOutcome(
            patternKind: pattern,
            involvedTiles: tiles,
            foodYield: foodYield,
            staminaYield: staminaYield,
            healthYield: healthYield,
            attackPotency: attackPotency
        )
    }

    private func applyMeldRewards(_ outcome: MeldEvaluationOutcome) {
        vitalityLedger.replenishFood(outcome.foodYield)
        vitalityLedger.replenishStamina(outcome.staminaYield)
        vitalityLedger.replenishHealth(outcome.healthYield)
        vitalityLedger.augmentScore(outcome.patternKind.rewardCoefficient * 10 * modeConfig.scoreMultiplier)
    }

    // MARK: - Discard
    func discardTileAtIndex(_ index: Int) {
        guard index >= 0 && index < handPalette.count else { return }
        handPalette.remove(at: index)
        emitAchievements(AchievementVault.shared.recordDiscard())
    }

    // MARK: - End Turn
    func concludeCurrentTurn() {
        let decayResult = vitalityLedger.executeEndOfTurnDecay()
        delegate?.engineDidAdvanceTurn(self, dayIndex: vitalityLedger.elapsedDayCount, decayInfo: decayResult)
        delegate?.engineDidRefreshVitals(self)

        // Achievement: turn-end checks
        let healthFull = vitalityLedger.currentHealth == vitalityLedger.healthCeiling
        emitAchievements(AchievementVault.shared.recordTurnEnd(
            dayIndex: vitalityLedger.elapsedDayCount,
            score: vitalityLedger.accumulatedScore,
            isStarving: vitalityLedger.isStarving,
            healthFull: healthFull
        ))

        if vitalityLedger.isExpired {
            currentPhase = .defeated
            emitAchievements(AchievementVault.shared.recordGameEnd())
            delegate?.engineDidReachDefeat(self, finalDay: vitalityLedger.elapsedDayCount, finalScore: vitalityLedger.accumulatedScore)
            return
        }

        // Check for event
        if vitalityLedger.elapsedDayCount % eventTriggerInterval == 0 && vitalityLedger.elapsedDayCount > 0 {
            let incident = IncidentForgeFactory.fabricateRandomIncident(forDay: vitalityLedger.elapsedDayCount, modeConfig: modeConfig)
            pendingIncident = incident
            currentPhase = .eventEncounter
            delegate?.engineDidTriggerIncident(self, incident: incident)
        } else {
            currentPhase = .drawingTile
        }
    }

    // MARK: - Event Resolution
    func resolveIncidentWithMeld(_ selectedIndices: [Int]) {
        guard currentPhase == .eventEncounter, let incident = pendingIncident else { return }

        let validIndices = selectedIndices.filter { $0 >= 0 && $0 < handPalette.count }
        let selectedTiles = validIndices.map { handPalette[$0] }
        let achievedPattern = recognizeMeldPattern(selectedTiles)

        var isSuccessful = false

        if let requiredKind = incident.requiredMeldKind {
            isSuccessful = (achievedPattern == requiredKind ||
                           achievedPattern == .winningHand ||
                           (requiredKind == .pair && (achievedPattern == .triplet || achievedPattern == .quartet)))
        } else {
            isSuccessful = (achievedPattern != .debris)
        }

        if isSuccessful {
            // Remove used tiles
            for idx in validIndices.sorted().reversed() {
                handPalette.remove(at: idx)
            }
            var foodBonus = incident.foodBonusOnSuccess
            // Daily affix: 顺子加餐（对顺子和事件按需加餐）
            if let required = incident.requiredMeldKind,
               required == .sequence,
               modeConfig.dailyAffixes.contains(where: { $0.id == "affix_chain_meal" }) {
                foodBonus += 1
            }
            vitalityLedger.replenishFood(foodBonus)
            vitalityLedger.replenishStamina(incident.staminaBonusOnSuccess)
            vitalityLedger.replenishHealth(incident.healthBonusOnSuccess)
            vitalityLedger.augmentScore(20 * modeConfig.scoreMultiplier)
            emitAchievements(AchievementVault.shared.recordEventWin(category: incident.category))
        } else {
            vitalityLedger.inflictDamage(incident.healthPenaltyOnFail)
            if incident.foodPenaltyOnFail > 0 {
                vitalityLedger.replenishFood(-incident.foodPenaltyOnFail)
            }
            if incident.staminaPenaltyOnFail > 0 {
                vitalityLedger.replenishStamina(-incident.staminaPenaltyOnFail)
            }

            // Thunderstorm failure: random discard 1
            if incident.category == .thunderstorm, !handPalette.isEmpty {
                _ = handPalette.remove(at: Int.random(in: 0..<handPalette.count))
            }
        }

        pendingIncident = nil
        delegate?.engineDidResolveIncident(self, incident: incident, wasSuccessful: isSuccessful)
        delegate?.engineDidRefreshVitals(self)

        if vitalityLedger.isExpired {
            currentPhase = .defeated
            delegate?.engineDidReachDefeat(self, finalDay: vitalityLedger.elapsedDayCount, finalScore: vitalityLedger.accumulatedScore)
        } else {
            currentPhase = .drawingTile
        }
    }

    func skipIncidentEncounter() {
        guard currentPhase == .eventEncounter, let incident = pendingIncident else { return }

        if incident.isHostile {
            vitalityLedger.inflictDamage(incident.healthPenaltyOnFail)
            vitalityLedger.replenishFood(-incident.foodPenaltyOnFail)
            vitalityLedger.replenishStamina(-incident.staminaPenaltyOnFail)
        }

        pendingIncident = nil
        delegate?.engineDidResolveIncident(self, incident: incident, wasSuccessful: false)
        delegate?.engineDidRefreshVitals(self)

        if vitalityLedger.isExpired {
            currentPhase = .defeated
            delegate?.engineDidReachDefeat(self, finalDay: vitalityLedger.elapsedDayCount, finalScore: vitalityLedger.accumulatedScore)
        } else {
            currentPhase = .drawingTile
        }
    }

    // MARK: - Achievement Helper
    private func emitAchievements(_ medals: [AchievementMedal]) {
        guard !medals.isEmpty else { return }
        delegate?.engineDidUnlockAchievements(self, medals: medals)
    }
}
