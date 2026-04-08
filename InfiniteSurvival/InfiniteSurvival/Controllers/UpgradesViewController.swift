import UIKit

final class UpgradesViewController: UIViewController {
    private let coinsLabel = UILabel()

    private let healthRow = UpgradeRow(title: "Max Health", attr: .health)
    private let foodRow = UpgradeRow(title: "Max Food", attr: .food)
    private let staminaRow = UpgradeRow(title: "Max Stamina", attr: .stamina)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PrismPaletteProvider.panelSurface.withAlphaComponent(0.95)

        let title = UILabel()
        title.text = "Upgrades"
        title.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        title.textColor = PrismPaletteProvider.textPrimary
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        coinsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        coinsLabel.textColor = UIColor(hex: "#FFD700")
        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coinsLabel)

        let stack = UIStackView(arrangedSubviews: [healthRow, foodRow, staminaRow])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            coinsLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            coinsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stack.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])

        healthRow.onUpgrade = { [weak self] in self?.handleUpgrade(.health) }
        foodRow.onUpgrade = { [weak self] in self?.handleUpgrade(.food) }
        staminaRow.onUpgrade = { [weak self] in self?.handleUpgrade(.stamina) }

        refresh()
    }

    private func refresh() {
        let vault = PlayerProgressVault.shared
        coinsLabel.text = "Coins: \(vault.coins)"

        healthRow.refresh()
        foodRow.refresh()
        staminaRow.refresh()
    }

    private func handleUpgrade(_ attr: ProgressAttribute) {
        if PlayerProgressVault.shared.performUpgrade(attr) {
            FeedbackFX.shared.tapSuccess()
            refresh()
        } else {
            FeedbackFX.shared.tapError()
        }
    }
}

private final class UpgradeRow: UIView {
    let attr: ProgressAttribute
    var onUpgrade: (() -> Void)?

    private let titleLabel = UILabel()
    private let levelLabel = UILabel()
    private let costButton = LuminousActionButton()

    init(title: String, attr: ProgressAttribute) {
        self.attr = attr
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.textColor = PrismPaletteProvider.textPrimary
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        levelLabel.textColor = PrismPaletteProvider.textSecondary
        levelLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)

        // Make the upgrade CTA more prominent
        costButton.applyGradientScheme(startColor: UIColor(hex: "#FFB300"), endColor: UIColor(hex: "#FF6F00"))
        costButton.layer.borderWidth = 1
        costButton.layer.borderColor = UIColor(hex: "#FFC107").cgColor
        costButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        costButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        costButton.addTarget(self, action: #selector(tap), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [titleLabel, levelLabel, costButton])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        // Fixed width for the upgrade button to keep all rows consistent and leave room for values
        let buttonWidth = costButton.widthAnchor.constraint(equalToConstant: 120)
        buttonWidth.priority = .required

        // Make title compress first if needed; keep value label visible
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        levelLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        levelLabel.adjustsFontSizeToFitWidth = true
        levelLabel.minimumScaleFactor = 0.85

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonWidth
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func refresh() {
        let vault = PlayerProgressVault.shared
        let level: Int
        switch attr {
        case .health: level = vault.healthLevel
        case .food: level = vault.foodLevel
        case .stamina: level = vault.staminaLevel
        }
        let cost = vault.cost(for: attr)
        let base: Int = {
            switch attr { case .health: return 20; case .food, .stamina: return 10 }
        }()
        let value = base + level
        levelLabel.text = "Lv. \(level)  •  Value: \(value)"
        if let c = cost {
            costButton.setTitle("Upgrade (\(c))", for: .normal)
            costButton.isEnabled = vault.coins >= c
            costButton.alpha = costButton.isEnabled ? 1.0 : 0.5
        } else {
            costButton.setTitle("Maxed", for: .normal)
            costButton.isEnabled = false
            costButton.alpha = 0.6
        }
    }

    @objc private func tap() {
        onUpgrade?()
    }
}
