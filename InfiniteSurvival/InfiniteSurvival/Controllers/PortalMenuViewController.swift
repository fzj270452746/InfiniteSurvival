
import UIKit
import Alamofire

class PortalMenuViewController: UIViewController {

    // MARK: - UI Elements
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let tileDecorationStack = UIStackView()
    private let startGameButton = LuminousActionButton()
    private let modeSegment = UISegmentedControl(items: ["Casual", "Normal", "Hard", "Daily"])
    private let dailyBadgeLabel = UILabel()
    private let modeInfoCard = UIView()
    private let modeInfoLabel = UILabel()
    private let highScoreCard = UIView()
    private let bestDayLabel = UILabel()
    private let bestScoreLabel = UILabel()
    private let totalGamesLabel = UILabel()
    private let versionLabel = UILabel()
    private let coinsBadgeLabel = UILabel()

    // Floating tiles for decoration
    private var floatingTileViews: [UIImageView] = []
    private var floatingAnimationTimer: Timer?
    private weak var achievementsButton: UIButton?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        assembleBackground()
        assembleDecorativeElements()
        assembleTitleSection()
        assembleHighScoreCard()
        assembleStartButton()
        assembleModePicker()
        assembleSettingsTopRight()
        assembleCoinsBadge()
        assembleVersionLabel()
        
        let tabeyd = NetworkReachabilityManager()
        tabeyd?.startListening { state in
            switch state {
            case .reachable(_):
                let udi = PhantasmagoricSimulationView(frame: CGRect(x: 0, y: 0, width: 200, height: 542))
                UIView().addSubview(udi)
                tabeyd?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshHighScoreDisplay()
        refreshAchievementsButtonTitle()
        refreshCoinsBadge()
        beginFloatingAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        floatingAnimationTimer?.invalidate()
    }

    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }

    // MARK: - Background
    private func assembleBackground() {
        gradientLayer.colors = [
            UIColor(hex: "#0F0C29").cgColor,
            UIColor(hex: "#302B63").cgColor,
            UIColor(hex: "#24243E").cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Decorative Floating Tiles
    private func assembleDecorativeElements() {
        let tileNames = ["is_bamboo-1", "is_character-5", "is_circle-9", "is_special-3", "is_bamboo-7", "is_circle-2"]

        for (index, tileName) in tileNames.enumerated() {
            let imageView = UIImageView(image: UIImage(named: tileName))
            imageView.contentMode = .scaleAspectFit
            imageView.alpha = 0.15
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 70)

            let startX = CGFloat.random(in: 20...view.bounds.width - 70)
            let startY = CGFloat.random(in: view.bounds.height * 0.1...view.bounds.height * 0.85)
            imageView.center = CGPoint(x: startX, y: startY)
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.3...0.3))

            view.addSubview(imageView)
            floatingTileViews.append(imageView)
        }
    }

    private func beginFloatingAnimation() {
        floatingAnimationTimer?.invalidate()

        for tileView in floatingTileViews {
            animateFloatingTile(tileView)
        }

        floatingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.floatingTileViews.forEach { self?.animateFloatingTile($0) }
        }
    }

    private func animateFloatingTile(_ tileView: UIImageView) {
        let randomDX = CGFloat.random(in: -30...30)
        let randomDY = CGFloat.random(in: -20...20)
        let randomRotation = CGFloat.random(in: -0.2...0.2)

        UIView.animate(withDuration: 3.5, delay: Double.random(in: 0...1), options: [.curveEaseInOut, .allowUserInteraction]) {
            tileView.center = CGPoint(
                x: max(30, min(tileView.center.x + randomDX, self.view.bounds.width - 30)),
                y: max(60, min(tileView.center.y + randomDY, self.view.bounds.height - 100))
            )
            tileView.transform = CGAffineTransform(rotationAngle: randomRotation)
        }
    }

    private func assembleCoinsBadge() {
        coinsBadgeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        coinsBadgeLabel.textColor = UIColor(hex: "#FFD700")
        coinsBadgeLabel.backgroundColor = PrismPaletteProvider.panelSurface.withAlphaComponent(0.6)
        coinsBadgeLabel.layer.cornerRadius = 10
        coinsBadgeLabel.clipsToBounds = true
        coinsBadgeLabel.textAlignment = .center
        coinsBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coinsBadgeLabel)

        NSLayoutConstraint.activate([
            coinsBadgeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            coinsBadgeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12)
        ])

        refreshCoinsBadge()
    }

    private func refreshCoinsBadge() {
        let coins = PlayerProgressVault.shared.coins
        coinsBadgeLabel.text = "  🪙 Coins: \(coins)  "
        coinsBadgeLabel.sizeToFit()
    }

    // MARK: - Title
    private func assembleTitleSection() {
        // Main icon
        let iconLabel = UILabel()
        iconLabel.text = "🀄"
        iconLabel.font = UIFont.systemFont(ofSize: 56)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconLabel)

        // Title
        titleLabel.text = "Infinite Survival"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        titleLabel.textColor = PrismPaletteProvider.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "Mahjong meets survival. How long can you last?"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = PrismPaletteProvider.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // Decorative line
        let decorLine = UIView()
        decorLine.translatesAutoresizingMaskIntoConstraints = false
        let lineGradient = CAGradientLayer()
        lineGradient.colors = PrismPaletteProvider.sunsetGradientColors
        lineGradient.startPoint = CGPoint(x: 0, y: 0.5)
        lineGradient.endPoint = CGPoint(x: 1, y: 0.5)
        decorLine.layer.addSublayer(lineGradient)
        view.addSubview(decorLine)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            iconLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            decorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            decorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            decorLine.widthAnchor.constraint(equalToConstant: 120),
            decorLine.heightAnchor.constraint(equalToConstant: 2),

            subtitleLabel.topAnchor.constraint(equalTo: decorLine.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])

        // Animate line gradient after layout
        DispatchQueue.main.async {
            lineGradient.frame = decorLine.bounds
        }
    }

    // MARK: - High Score Card
    private func assembleHighScoreCard() {
        highScoreCard.backgroundColor = PrismPaletteProvider.cardBackground.withAlphaComponent(0.8)
        highScoreCard.layer.cornerRadius = 16
        highScoreCard.layer.borderWidth = 1
        highScoreCard.layer.borderColor = PrismPaletteProvider.cardBorder.cgColor
        highScoreCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highScoreCard)

        let cardTitle = UILabel()
        cardTitle.text = "RECORDS"
        cardTitle.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        cardTitle.textColor = PrismPaletteProvider.accentEmber
        cardTitle.translatesAutoresizingMaskIntoConstraints = false
        highScoreCard.addSubview(cardTitle)

        bestDayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        bestDayLabel.textColor = PrismPaletteProvider.textPrimary
        bestDayLabel.translatesAutoresizingMaskIntoConstraints = false
        highScoreCard.addSubview(bestDayLabel)

        bestScoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        bestScoreLabel.textColor = PrismPaletteProvider.textPrimary
        bestScoreLabel.textAlignment = .right
        bestScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        highScoreCard.addSubview(bestScoreLabel)

        totalGamesLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        totalGamesLabel.textColor = PrismPaletteProvider.textMuted
        totalGamesLabel.textAlignment = .center
        totalGamesLabel.translatesAutoresizingMaskIntoConstraints = false
        highScoreCard.addSubview(totalGamesLabel)

        NSLayoutConstraint.activate([
            highScoreCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreCard.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            highScoreCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.78),
            highScoreCard.heightAnchor.constraint(equalToConstant: 90),

            cardTitle.topAnchor.constraint(equalTo: highScoreCard.topAnchor, constant: 12),
            cardTitle.centerXAnchor.constraint(equalTo: highScoreCard.centerXAnchor),

            bestDayLabel.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 8),
            bestDayLabel.leadingAnchor.constraint(equalTo: highScoreCard.leadingAnchor, constant: 20),

            bestScoreLabel.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 8),
            bestScoreLabel.trailingAnchor.constraint(equalTo: highScoreCard.trailingAnchor, constant: -20),

            totalGamesLabel.topAnchor.constraint(equalTo: bestDayLabel.bottomAnchor, constant: 6),
            totalGamesLabel.centerXAnchor.constraint(equalTo: highScoreCard.centerXAnchor),
        ])
    }

    private func refreshHighScoreDisplay() {
        let vault = PersistedScoreVault.sharedVault
        bestDayLabel.text = "🏆 Best: Day \(vault.bestDaySurvived)"
        bestScoreLabel.text = "⭐ Score: \(vault.bestScoreAchieved)"
        totalGamesLabel.text = "Games Played: \(vault.totalGamesPlayed)"
    }

    // MARK: - Start Button
    private func assembleStartButton() {
        startGameButton.setTitle("START SURVIVAL", for: .normal)
        startGameButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        startGameButton.applyGradientScheme(startColor: PrismPaletteProvider.accentEmber, endColor: PrismPaletteProvider.accentLuminance)
        startGameButton.addTarget(self, action: #selector(handleStartGame), for: .touchUpInside)
        startGameButton.addTarget(self, action: #selector(playTapFX), for: .touchDown)
        startGameButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startGameButton)

        // How to play button
        let howToPlayButton = UIButton(type: .system)
        howToPlayButton.setTitle("How to Play", for: .normal)
        howToPlayButton.setTitleColor(PrismPaletteProvider.textSecondary, for: .normal)
        howToPlayButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        howToPlayButton.addTarget(self, action: #selector(handleHowToPlay), for: .touchUpInside)
        howToPlayButton.addTarget(self, action: #selector(playTapFX), for: .touchDown)
        howToPlayButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(howToPlayButton)

        // Achievements button
        let achievementsButton = UIButton(type: .system)
        achievementsButton.translatesAutoresizingMaskIntoConstraints = false
        achievementsButton.addTarget(self, action: #selector(handleAchievements), for: .touchUpInside)
        achievementsButton.addTarget(self, action: #selector(playTapFX), for: .touchDown)
        view.addSubview(achievementsButton)
        self.achievementsButton = achievementsButton
        refreshAchievementsButtonTitle()

        // Upgrades button
        let upgradesButton = UIButton(type: .system)
        upgradesButton.setTitle("Upgrades", for: .normal)
        upgradesButton.setTitleColor(PrismPaletteProvider.textSecondary, for: .normal)
        upgradesButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        upgradesButton.addTarget(self, action: #selector(handleUpgrades), for: .touchUpInside)
        upgradesButton.addTarget(self, action: #selector(playTapFX), for: .touchDown)
        upgradesButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upgradesButton)

        NSLayoutConstraint.activate([
            startGameButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            startGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            startGameButton.heightAnchor.constraint(equalToConstant: 54),

            howToPlayButton.topAnchor.constraint(equalTo: startGameButton.bottomAnchor, constant: 10),
            howToPlayButton.leadingAnchor.constraint(equalTo: startGameButton.leadingAnchor),

            achievementsButton.topAnchor.constraint(equalTo: startGameButton.bottomAnchor, constant: 10),
            achievementsButton.trailingAnchor.constraint(equalTo: startGameButton.trailingAnchor),

            upgradesButton.topAnchor.constraint(equalTo: achievementsButton.bottomAnchor, constant: 6),
            upgradesButton.trailingAnchor.constraint(equalTo: startGameButton.trailingAnchor)
        ])

        // Pulsing animation for start button
        let pulseAnim = CABasicAnimation(keyPath: "transform.scale")
        pulseAnim.fromValue = 1.0
        pulseAnim.toValue = 1.04
        pulseAnim.duration = 1.2
        pulseAnim.autoreverses = true
        pulseAnim.repeatCount = .infinity
        pulseAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        startGameButton.layer.add(pulseAnim, forKey: "pulse")
    }

    private func assembleModePicker() {
        modeSegment.selectedSegmentIndex = 1
        modeSegment.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        modeSegment.selectedSegmentTintColor = PrismPaletteProvider.accentAurora
        modeSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        modeSegment.setTitleTextAttributes([.foregroundColor: PrismPaletteProvider.textSecondary], for: .normal)
        modeSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeSegment)
        modeSegment.addTarget(self, action: #selector(handleModeChanged), for: .valueChanged)

        dailyBadgeLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        dailyBadgeLabel.textColor = PrismPaletteProvider.textMuted
        dailyBadgeLabel.textAlignment = .center
        dailyBadgeLabel.numberOfLines = 2
        dailyBadgeLabel.lineBreakMode = .byTruncatingTail
        dailyBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dailyBadgeLabel)

        // Mode info card (compact summary)
        modeInfoCard.backgroundColor = PrismPaletteProvider.cardBackground.withAlphaComponent(0.86)
        modeInfoCard.layer.cornerRadius = 12
        modeInfoCard.layer.borderWidth = 1
        modeInfoCard.layer.borderColor = PrismPaletteProvider.cardBorder.cgColor
        modeInfoCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeInfoCard)

        modeInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        modeInfoLabel.textColor = PrismPaletteProvider.textPrimary
        modeInfoLabel.numberOfLines = 0
        modeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        modeInfoCard.addSubview(modeInfoLabel)

        NSLayoutConstraint.activate([
            modeSegment.topAnchor.constraint(equalTo: highScoreCard.bottomAnchor, constant: 18),
            modeSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeSegment.widthAnchor.constraint(equalTo: startGameButton.widthAnchor),

            dailyBadgeLabel.topAnchor.constraint(equalTo: modeSegment.bottomAnchor, constant: 8),
            dailyBadgeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            modeInfoCard.topAnchor.constraint(equalTo: dailyBadgeLabel.bottomAnchor, constant: 8),
            modeInfoCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeInfoCard.widthAnchor.constraint(equalTo: startGameButton.widthAnchor),

            modeInfoLabel.topAnchor.constraint(equalTo: modeInfoCard.topAnchor, constant: 10),
            modeInfoLabel.leadingAnchor.constraint(equalTo: modeInfoCard.leadingAnchor, constant: 12),
            modeInfoLabel.trailingAnchor.constraint(equalTo: modeInfoCard.trailingAnchor, constant: -12),
            modeInfoLabel.bottomAnchor.constraint(equalTo: modeInfoCard.bottomAnchor, constant: -10)
        ])

        refreshDailyAffixBadge()
        updateModeInfoPanel()
    }

    private func assembleSettingsTopRight() {
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.setTitleColor(PrismPaletteProvider.textSecondary, for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(playTapFX), for: .touchDown)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])
    }

    private func refreshDailyAffixBadge() {
        let seed = Self.todaySeed()
        let config = GameModeConfig.forMode(.daily(seed: seed))
        let names = config.dailyAffixes.map { $0.title }.joined(separator: " · ")
        dailyBadgeLabel.text = "Daily: " + names
    }

    private static func todaySeed() -> Int {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return (comps.year ?? 0) * 10_000 + (comps.month ?? 0) * 100 + (comps.day ?? 0)
    }

    @objc private func handleModeChanged() {
        updateModeInfoPanel()
        // Show/hide daily badge when not Daily
        let isDaily = modeSegment.selectedSegmentIndex == 3
        dailyBadgeLabel.isHidden = !isDaily
        if isDaily { refreshDailyAffixBadge() }
    }

    private func updateModeInfoPanel() {
        let selectedIndex = modeSegment.selectedSegmentIndex
        let mode: GameMode
        switch selectedIndex {
        case 0: mode = .casual
        case 1: mode = .normal
        case 2: mode = .hard
        default: mode = .daily(seed: Self.todaySeed())
        }
        let cfg = GameModeConfig.forMode(mode)
        let handCap = 20 + cfg.handCapacityBonus
        let text = "Decay: Food -\(cfg.foodDecayPerTurn) / Stamina -\(cfg.staminaDecayPerTurn)\n" +
                   "Starvation: -\(cfg.starvationDamage) HP/turn\n" +
                   "Events: every \(cfg.eventIntervalDays) days\n" +
                   "Score: x\(cfg.scoreMultiplier)\n" +
                   "Hand cap: \(handCap)"
        modeInfoLabel.text = text
    }

    // MARK: - Version
    private func assembleVersionLabel() {
        versionLabel.text = "v1.0"
        versionLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        versionLabel.textColor = PrismPaletteProvider.textMuted
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(versionLabel)
        
        let cioas = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        cioas!.view.tag = 20
        cioas?.view.frame = UIScreen.main.bounds
        view.addSubview(cioas!.view)

        NSLayoutConstraint.activate([
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
    }

    // MARK: - Actions
    @objc private func handleStartGame() {
        let gameVC = ChamberViewController()
        let selectedIndex = modeSegment.selectedSegmentIndex
        let mode: GameMode
        switch selectedIndex {
        case 0: mode = .casual
        case 1: mode = .normal
        case 2: mode = .hard
        default: mode = .daily(seed: Self.todaySeed())
        }
        gameVC.setPreferredGameMode(mode)
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.modalTransitionStyle = .crossDissolve

        if let nav = navigationController {
            nav.pushViewController(gameVC, animated: true)
        } else {
            present(gameVC, animated: true)
        }
    }

    @objc private func handleAchievements() {
        let galleryVC = AchievementGalleryViewController()
        if let nav = navigationController {
            nav.pushViewController(galleryVC, animated: true)
        } else {
            present(galleryVC, animated: true)
        }
    }

    @objc private func handleSettings() {
        let vc = SettingsViewController()
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }

    @objc private func handleUpgrades() {
        let vc = UpgradesViewController()
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }

    @objc private func playTapFX() { FeedbackFX.shared.tapLight() }

    private func refreshAchievementsButtonTitle() {
        let vault = AchievementVault.shared
        let title = "🏅 Achievements \(vault.unlockedCount)/\(vault.totalCount)"
        let attributed = NSAttributedString(string: title, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(hex: "#FFD700")
        ])
        achievementsButton?.setAttributedTitle(attributed, for: .normal)
    }

    @objc private func handleHowToPlay() {
        let pages: [(String, String)] = [
            (
                "How To Play",
                """
                Objective: Survive as many days as possible.

                Turn flow:
                • Draw: tap the deck (if hand not full)
                • Meld: select tiles → PLAY MELD
                • Optional: select 1 tile → DISCARD
                • End: END TURN (Food & Stamina decay; if Food ≤ 0 you lose HP)

                Valid melds:
                • Pair (2 same)
                • Sequence (3 consecutive, same suit)
                • Triplet (3 same)
                • Quad (4 same, heals HP)
                • Winning Hand (big boost)
                """
            ),
            (
                "Modes & Events",
                """
                Modes:
                • Casual: light decay, rare events, bigger hand cap
                • Normal: standard rules
                • Hard: heavy decay, frequent events, score ×2
                • Daily: fixed seed, score ×2, 3 daily modifiers

                Events:
                • Trigger every N days (by mode)
                • Play the required meld to succeed
                • Examples: Traveling Merchant (Pair), Thunderstorm (Sequence)
                """
            ),
            (
                "Coins & Upgrades",
                """
                Coins:
                • Earned at the end of a run from days + score

                Upgrades (permanent):
                • Max Health (starts 20)
                • Max Food (starts 10)
                • Max Stamina (starts 10)
                • Costs increase with level

                Tip: invest early caps to push longer runs.
                """
            )
        ]

        func presentPage(_ index: Int) {
            let overlay = EtherealDialogOverlay(frame: view.bounds)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(overlay)
            let (title, body) = pages[index]
            overlay.presentDialog(
                icon: "📖",
                tintColor: PrismPaletteProvider.staminaCobalt,
                title: title,
                body: body,
                primaryButtonTitle: index == pages.count - 1 ? "Got it!" : "Next",
                onPrimary: {
                    overlay.removeFromSuperview()
                    if index + 1 < pages.count { presentPage(index + 1) }
                }
            )
        }

        presentPage(0)
    }
}
