//
//  ChamberViewController.swift
//  InfiniteSurvival
//
//  Main game view controller - integrates UIKit HUD with SpriteKit arena
//

import UIKit
import SpriteKit

class ChamberViewController: UIViewController {

    // MARK: - Engine
    private let orchestrationEngine = OrchestrationEngine()
    private var preferredMode: GameMode = .normal

    // MARK: - SpriteKit
    private var arenaScene: MahjongArenaScene!
    private var spriteKitView: SKView!

    // MARK: - HUD Elements
    private let vitalityPanel = UIView()
    private let healthGauge = RadiantGaugeStrip()
    private let foodGauge = RadiantGaugeStrip()
    private let staminaGauge = RadiantGaugeStrip()
    private let headerBar = UIView()
    private let backButton = UIButton(type: .system)
    private let dayCounterLabel = UILabel()
    private let scoreDisplayLabel = UILabel()

    // MARK: - Action Buttons
    private let actionToolbar = UIView()
    private let meldSubmitButton = LuminousActionButton()
    private let endTurnButton = LuminousActionButton()
    private let discardButton = LuminousActionButton()

    // MARK: - Overlays
    private let dialogOverlay = EtherealDialogOverlay()
    private let notificationBanner = ArcaneNotificationBanner()

    // MARK: - State
    private var currentSelectedIndices: [Int] = []
    private var achievementDisplayQueue: [AchievementMedal] = []
    private var isShowingAchievement = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PrismPaletteProvider.canvasBackdrop
        assembleGradientBackground()
        assembleSpriteKitView()
        assembleVitalityPanel()
        assembleActionToolbar()
        assembleOverlays()
        configureEngine()
        orchestrationEngine.commenceNewSession(mode: preferredMode)
    }

    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }

    // MARK: - Background
    private func assembleGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = PrismPaletteProvider.heroGradientColors
        gradientLayer.locations = [0, 0.5, 1]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - SpriteKit View
    private func assembleSpriteKitView() {
        spriteKitView = SKView()
        spriteKitView.translatesAutoresizingMaskIntoConstraints = false
        spriteKitView.allowsTransparency = true
        spriteKitView.backgroundColor = .clear
        view.addSubview(spriteKitView)

        NSLayoutConstraint.activate([
            spriteKitView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            spriteKitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spriteKitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spriteKitView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update gradient
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }

        // Setup scene once we have correct bounds
        if arenaScene == nil {
            let sceneSize = spriteKitView.bounds.size
            guard sceneSize.width > 0 && sceneSize.height > 0 else { return }

            arenaScene = MahjongArenaScene(size: sceneSize)
            arenaScene.scaleMode = .resizeFill
            arenaScene.arenaDelegate = self
            spriteKitView.presentScene(arenaScene)

            // Refresh display
            refreshHandDisplay()
            refreshVitalityDisplay()
            arenaScene.refreshDeckCount(orchestrationEngine.tilePondReservoir.count)
        }
    }

    // MARK: - Vitality Panel
    private func assembleVitalityPanel() {
        // Header bar: Day + Score side by side, prominent
        headerBar.backgroundColor = PrismPaletteProvider.panelSurface.withAlphaComponent(0.9)
        headerBar.layer.cornerRadius = 12
        headerBar.layer.borderWidth = 1
        headerBar.layer.borderColor = PrismPaletteProvider.cardBorder.cgColor
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerBar)

        // Back button - left side
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = PrismPaletteProvider.textSecondary
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        headerBar.addSubview(backButton)

        // Day counter - prominent, after back button
        dayCounterLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .heavy)
        dayCounterLabel.textColor = PrismPaletteProvider.accentEmber
        dayCounterLabel.text = "DAY 0"
        dayCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        headerBar.addSubview(dayCounterLabel)

        // Score - right side
        scoreDisplayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        scoreDisplayLabel.textColor = PrismPaletteProvider.accentLuminance
        scoreDisplayLabel.text = "SCORE 0"
        scoreDisplayLabel.textAlignment = .right
        scoreDisplayLabel.translatesAutoresizingMaskIntoConstraints = false
        headerBar.addSubview(scoreDisplayLabel)

        // Vitality panel below header
        vitalityPanel.backgroundColor = PrismPaletteProvider.panelSurface.withAlphaComponent(0.85)
        vitalityPanel.layer.cornerRadius = 12
        vitalityPanel.layer.borderWidth = 1
        vitalityPanel.layer.borderColor = PrismPaletteProvider.cardBorder.cgColor
        vitalityPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vitalityPanel)

        // Configure gauges
        healthGauge.configureAppearance(icon: "❤️", label: "Health", tint: PrismPaletteProvider.healthCrimson, dimTint: PrismPaletteProvider.healthCrimsonDim)
        foodGauge.configureAppearance(icon: "🍗", label: "Food", tint: PrismPaletteProvider.foodEmerald, dimTint: PrismPaletteProvider.foodEmeraldDim)
        staminaGauge.configureAppearance(icon: "⚡", label: "Stamina", tint: PrismPaletteProvider.staminaCobalt, dimTint: PrismPaletteProvider.staminaCobaltDim)

        let gaugeStack = UIStackView(arrangedSubviews: [healthGauge, foodGauge, staminaGauge])
        gaugeStack.axis = .vertical
        gaugeStack.spacing = 4
        gaugeStack.distribution = .fillEqually
        gaugeStack.translatesAutoresizingMaskIntoConstraints = false
        vitalityPanel.addSubview(gaugeStack)

        NSLayoutConstraint.activate([
            // Header bar
            headerBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            headerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            headerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            headerBar.heightAnchor.constraint(equalToConstant: 36),

            dayCounterLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 6),
            dayCounterLabel.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),

            backButton.leadingAnchor.constraint(equalTo: headerBar.leadingAnchor, constant: 10),
            backButton.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            scoreDisplayLabel.trailingAnchor.constraint(equalTo: headerBar.trailingAnchor, constant: -14),
            scoreDisplayLabel.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),

            // Vitality panel
            vitalityPanel.topAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: 4),
            vitalityPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            vitalityPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            vitalityPanel.heightAnchor.constraint(equalToConstant: 80),

            gaugeStack.topAnchor.constraint(equalTo: vitalityPanel.topAnchor, constant: 8),
            gaugeStack.leadingAnchor.constraint(equalTo: vitalityPanel.leadingAnchor, constant: 12),
            gaugeStack.trailingAnchor.constraint(equalTo: vitalityPanel.trailingAnchor, constant: -12),
            gaugeStack.bottomAnchor.constraint(equalTo: vitalityPanel.bottomAnchor, constant: -8),
        ])
    }

    // MARK: - Action Toolbar
    private func assembleActionToolbar() {
        actionToolbar.backgroundColor = PrismPaletteProvider.panelSurface.withAlphaComponent(0.9)
        actionToolbar.layer.cornerRadius = 16
        actionToolbar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        actionToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionToolbar)

        // Configure buttons
        meldSubmitButton.setTitle("PLAY MELD", for: .normal)
        meldSubmitButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        meldSubmitButton.applyGradientScheme(startColor: PrismPaletteProvider.accentEmber, endColor: PrismPaletteProvider.accentLuminance)
        meldSubmitButton.addTarget(self, action: #selector(handleMeldSubmission), for: .touchUpInside)
        meldSubmitButton.addTarget(self, action: #selector(tapFeedback), for: .touchDown)
        meldSubmitButton.isEnabled = false

        endTurnButton.setTitle("END TURN", for: .normal)
        endTurnButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        endTurnButton.applyGradientScheme(startColor: PrismPaletteProvider.buttonSecondary, endColor: PrismPaletteProvider.accentAurora)
        endTurnButton.addTarget(self, action: #selector(handleEndTurn), for: .touchUpInside)
        endTurnButton.addTarget(self, action: #selector(tapFeedback), for: .touchDown)

        discardButton.setTitle("DISCARD", for: .normal)
        discardButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        discardButton.applyGradientScheme(startColor: UIColor(hex: "#555577"), endColor: UIColor(hex: "#333355"))
        discardButton.addTarget(self, action: #selector(handleDiscardTile), for: .touchUpInside)
        discardButton.addTarget(self, action: #selector(tapFeedback), for: .touchDown)
        discardButton.isEnabled = false

        let buttonStack = UIStackView(arrangedSubviews: [discardButton, meldSubmitButton, endTurnButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        actionToolbar.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            actionToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            actionToolbar.heightAnchor.constraint(equalToConstant: 80),

            buttonStack.topAnchor.constraint(equalTo: actionToolbar.topAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: actionToolbar.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: actionToolbar.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func tapFeedback() { FeedbackFX.shared.tapLight() }

    // MARK: - Overlays
    private func assembleOverlays() {
        dialogOverlay.frame = view.bounds
        dialogOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(dialogOverlay)

        notificationBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationBanner)

        NSLayoutConstraint.activate([
            notificationBanner.topAnchor.constraint(equalTo: vitalityPanel.bottomAnchor, constant: 8),
            notificationBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notificationBanner.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            notificationBanner.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }

    // MARK: - Engine Config
    private func configureEngine() {
        orchestrationEngine.delegate = self
        // First-run tutorial: present gentle guidance for first game only
        if UserDefaults.standard.bool(forKey: "is_tutorial_done") == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.dialogOverlay.presentDialog(
                    icon: "🧭",
                    tintColor: PrismPaletteProvider.accentAurora,
            title: "Welcome Tutorial",
            body: "Tap deck to draw → select two tiles for a Pair → tap PLAY MELD.",
            primaryButtonTitle: "Start",
            onPrimary: { UserDefaults.standard.set(true, forKey: "is_tutorial_done") }
        )
            }
        }
    }

    // MARK: - Display Refresh
    private func refreshVitalityDisplay() {
        let ledger = orchestrationEngine.vitalityLedger
        healthGauge.refreshGauge(currentValue: ledger.currentHealth, maximumValue: ledger.healthCeiling)
        foodGauge.refreshGauge(currentValue: ledger.currentFood, maximumValue: ledger.foodCeiling)
        staminaGauge.refreshGauge(currentValue: ledger.currentStamina, maximumValue: ledger.staminaCeiling)
        dayCounterLabel.text = "DAY \(ledger.elapsedDayCount)"
        scoreDisplayLabel.text = "SCORE \(ledger.accumulatedScore)"
    }

    private func refreshHandDisplay() {
        arenaScene?.renderHandTiles(orchestrationEngine.handPalette)
    }

    // MARK: - Button States
    private func refreshButtonStates() {
        let hasSelection = !currentSelectedIndices.isEmpty
        meldSubmitButton.isEnabled = currentSelectedIndices.count >= 2
        discardButton.isEnabled = currentSelectedIndices.count == 1
    }

    // MARK: - Actions
    @objc private func handleBackTapped() {
        dialogOverlay.presentDialog(
            icon: "⚠️",
            tintColor: PrismPaletteProvider.accentLuminance,
            title: "Leave Game?",
            body: "Current progress will be lost.",
            primaryButtonTitle: "Leave",
            secondaryButtonTitle: "Cancel",
            onPrimary: { [weak self] in
                self?.navigateToMainMenu()
            },
            onSecondary: { }
        )
    }

    @objc private func handleMeldSubmission() {
        guard currentSelectedIndices.count >= 2 else { return }

        if orchestrationEngine.currentPhase == .eventEncounter {
            orchestrationEngine.resolveIncidentWithMeld(currentSelectedIndices)
        } else {
            let result = orchestrationEngine.evaluateSelectedTiles(currentSelectedIndices)
            if let outcome = result, outcome.patternKind == .debris {
                notificationBanner.flashBanner(
                    icon: "❌",
                    title: "No Valid Pattern",
                    subtitle: "Select tiles forming a Pair, Sequence, Triplet, or Quad",
                    colors: [UIColor(hex: "#FF4444").cgColor, UIColor(hex: "#CC0000").cgColor]
                )
                arenaScene?.clearAllSelections()
                FeedbackFX.shared.tapError()
            }
        }

        currentSelectedIndices.removeAll()
        refreshButtonStates()
    }

    @objc private func handleEndTurn() {
        orchestrationEngine.concludeCurrentTurn()
        currentSelectedIndices.removeAll()
        arenaScene?.clearAllSelections()
        refreshButtonStates()
        FeedbackFX.shared.tapLight()
    }

    @objc private func handleDiscardTile() {
        guard currentSelectedIndices.count == 1 else { return }
        let index = currentSelectedIndices[0]
        orchestrationEngine.discardTileAtIndex(index)
        currentSelectedIndices.removeAll()
        refreshHandDisplay()
        refreshButtonStates()
        FeedbackFX.shared.play("discard")
    }

    // MARK: - Game Over
    private func presentDefeatScreen(finalDay: Int, finalScore: Int) {
        PersistedScoreVault.sharedVault.submitSessionResult(daySurvived: finalDay, score: finalScore)
        let coins = PlayerProgressVault.shared.awardCoins(forDay: finalDay, score: finalScore)

        let bestDay = PersistedScoreVault.sharedVault.bestDaySurvived
        let isNewRecord = finalDay >= bestDay

        dialogOverlay.presentDialog(
            icon: isNewRecord ? "🏆" : "💀",
            tintColor: isNewRecord ? UIColor(hex: "#FFD700") : PrismPaletteProvider.accentEmber,
            title: isNewRecord ? "New Record!" : "Defeated",
            body: "Survived \(finalDay) days\nScore: \(finalScore)\nBest: \(bestDay) days\n\nCoins +\(coins)",
            primaryButtonTitle: "Try Again",
            secondaryButtonTitle: "Main Menu",
            onPrimary: { [weak self] in
                guard let self = self else { return }
                self.orchestrationEngine.commenceNewSession(mode: self.preferredMode)
            },
            onSecondary: { [weak self] in
                self?.navigateToMainMenu()
            }
        )
        FeedbackFX.shared.play("defeat")
    }

    private func navigateToMainMenu() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - MahjongArenaSceneDelegate
extension ChamberViewController: MahjongArenaSceneDelegate {

    func arenaDidSelectTiles(_ scene: MahjongArenaScene, selectedIndices: [Int]) {
        currentSelectedIndices = selectedIndices
        refreshButtonStates()
    }

    func arenaDidRequestDraw(_ scene: MahjongArenaScene) {
        orchestrationEngine.performTileDraw()
    }

    func arenaDidRequestDiscard(_ scene: MahjongArenaScene, tileIndex: Int) {
        orchestrationEngine.discardTileAtIndex(tileIndex)
        refreshHandDisplay()
    }
}

// MARK: - OrchestrationEngineDelegate
extension ChamberViewController: OrchestrationEngineDelegate {

    func engineDidRefreshVitals(_ engine: OrchestrationEngine) {
        refreshVitalityDisplay()
    }

    func engineDidDealHandTiles(_ engine: OrchestrationEngine, tiles: [CeramicTileUnit]) {
        refreshHandDisplay()
    }

    func engineDidDrawTile(_ engine: OrchestrationEngine, tile: CeramicTileUnit) {
        refreshHandDisplay()
        arenaScene?.refreshDeckCount(engine.tilePondReservoir.count)

        notificationBanner.flashBanner(
            icon: tile.vesselSuit.displayEmblem,
            title: "Drew \(tile.vesselSuit.rawValue.capitalized) \(tile.numericRank)",
            subtitle: "Select tiles to form melds",
            duration: 1.5
        )
        FeedbackFX.shared.play("draw")
        FeedbackFX.shared.tapLight()
    }

    func engineDidEvaluateMeld(_ engine: OrchestrationEngine, outcome: MeldEvaluationOutcome) {
        arenaScene?.playMeldCelebration(pattern: outcome.patternKind, atIndices: [])
        refreshHandDisplay()

        var rewardText = ""
        if outcome.foodYield > 0 { rewardText += "+\(outcome.foodYield) Food " }
        if outcome.staminaYield > 0 { rewardText += "+\(outcome.staminaYield) Stamina " }
        if outcome.healthYield > 0 { rewardText += "+\(outcome.healthYield) HP " }

        notificationBanner.flashBanner(
            icon: "✨",
            title: outcome.patternKind.displayTitle,
            subtitle: rewardText.isEmpty ? outcome.patternKind.displayCaption : rewardText,
            colors: PrismPaletteProvider.emeraldGradientColors
        )
        FeedbackFX.shared.play("meld")
        FeedbackFX.shared.tapSuccess()
    }

    func engineDidTriggerIncident(_ engine: OrchestrationEngine, incident: HappeningIncident) {
        let hexColor = incident.category.accentHexColor
        let tintColor = UIColor(hex: hexColor)

        var hintText = incident.category.narrativeCaption
        if let required = incident.requiredMeldKind {
            hintText += "\nRequired: \(required.displayTitle)"
        }

        dialogOverlay.presentDialog(
            icon: incident.category.themeIconName == "flame.fill" ? "🔥" : "⚡",
            tintColor: tintColor,
            title: incident.category.displayTitle,
            body: hintText,
            primaryButtonTitle: "Face It",
            secondaryButtonTitle: incident.isHostile ? nil : "Skip",
            onPrimary: { [weak self] in
                // Player will select tiles and submit
            },
            onSecondary: { [weak self] in
                self?.orchestrationEngine.skipIncidentEncounter()
            }
        )
    }

    func engineDidResolveIncident(_ engine: OrchestrationEngine, incident: HappeningIncident, wasSuccessful: Bool) {
        if wasSuccessful {
            notificationBanner.flashBanner(
                icon: "✅",
                title: "Success!",
                subtitle: "Event resolved successfully",
                colors: PrismPaletteProvider.emeraldGradientColors
            )
            FeedbackFX.shared.play("success")
            FeedbackFX.shared.tapSuccess()
        } else {
            notificationBanner.flashBanner(
                icon: "💔",
                title: "Failed!",
                subtitle: incident.isHostile ? "You took damage!" : "Opportunity missed",
                colors: [UIColor(hex: "#FF4444").cgColor, UIColor(hex: "#CC0000").cgColor]
            )
            FeedbackFX.shared.play("fail")
            FeedbackFX.shared.tapError()
        }
        refreshHandDisplay()
    }

    func engineDidAdvanceTurn(_ engine: OrchestrationEngine, dayIndex: Int, decayInfo: (foodLost: Int, staminaLost: Int, healthLost: Int)) {
        var decayText = "Food -\(decayInfo.foodLost), Stamina -\(decayInfo.staminaLost)"
        if decayInfo.healthLost > 0 {
            decayText += ", HP -\(decayInfo.healthLost) (Starving!)"
        }

        notificationBanner.flashBanner(
            icon: "🌙",
            title: "Day \(dayIndex)",
            subtitle: decayText,
            colors: [UIColor(hex: "#2C3E50").cgColor, UIColor(hex: "#4CA1AF").cgColor],
            duration: 2.5
        )
    }

    func engineDidReachDefeat(_ engine: OrchestrationEngine, finalDay: Int, finalScore: Int) {
        presentDefeatScreen(finalDay: finalDay, finalScore: finalScore)
    }

    func engineDidNotifyMessage(_ engine: OrchestrationEngine, title: String, body: String) {
        notificationBanner.flashBanner(icon: "ℹ️", title: title, subtitle: body)
    }

    func engineDidUnlockAchievements(_ engine: OrchestrationEngine, medals: [AchievementMedal]) {
        achievementDisplayQueue.append(contentsOf: medals)
        displayNextAchievement()
    }
}

// MARK: - Achievement Display
extension ChamberViewController {

    private func displayNextAchievement() {
        guard !isShowingAchievement, let medal = achievementDisplayQueue.first else { return }
        achievementDisplayQueue.removeFirst()
        isShowingAchievement = true

        let banner = AchievementBannerView(medal: medal)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.alpha = 0
        banner.transform = CGAffineTransform(translationX: 0, y: -60)
        view.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 140),
            banner.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            banner.heightAnchor.constraint(equalToConstant: 64),
        ])

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            banner.alpha = 1
            banner.transform = .identity
        }

        UIView.animate(withDuration: 0.3, delay: 2.5, options: .curveEaseIn) {
            banner.alpha = 0
            banner.transform = CGAffineTransform(translationX: 0, y: -30)
        } completion: { _ in
            banner.removeFromSuperview()
            self.isShowingAchievement = false
            self.displayNextAchievement()
        }
    }
}

// MARK: - Public API
extension ChamberViewController {
    func setPreferredGameMode(_ mode: GameMode) {
        preferredMode = mode
    }
}

// MARK: - Achievement Banner View
private class AchievementBannerView: UIView {

    init(medal: AchievementMedal) {
        super.init(frame: .zero)

        layer.cornerRadius = 14
        clipsToBounds = true

        // Gold gradient background
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: "#FFD700").cgColor, UIColor(hex: "#FFA500").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.88, height: 64)
        layer.insertSublayer(gradient, at: 0)

        // Dark overlay for readability
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)

        let iconLabel = UILabel()
        iconLabel.text = medal.icon
        iconLabel.font = .systemFont(ofSize: 28)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false

        let headerLabel = UILabel()
        headerLabel.text = "ACHIEVEMENT UNLOCKED"
        headerLabel.font = UIFont.systemFont(ofSize: 9, weight: .heavy)
        headerLabel.textColor = UIColor(hex: "#FFD700")
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = medal.title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [headerLabel, titleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconLabel)
        addSubview(textStack)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 36),

            textStack.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 10),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
