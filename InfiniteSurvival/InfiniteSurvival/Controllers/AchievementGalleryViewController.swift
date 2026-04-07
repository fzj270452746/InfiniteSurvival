//
//  AchievementGalleryViewController.swift
//  InfiniteSurvival
//
//  Achievement showcase grid with unlock status
//

import UIKit

class AchievementGalleryViewController: UIViewController {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let progressLabel = UILabel()
    private let catalog = AchievementMedal.fullCatalog

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PrismPaletteProvider.canvasBackdrop
        assembleGradientBackground()
        assembleNavigationBar()
        assembleProgressHeader()
        assembleCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProgress()
        collectionView.reloadData()
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - Background
    private func assembleGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = PrismPaletteProvider.heroGradientColors
        gradientLayer.locations = [0, 0.5, 1]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Nav Bar
    private func assembleNavigationBar() {
        let navBar = UIView()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = PrismPaletteProvider.textSecondary
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = "ACHIEVEMENTS"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        titleLabel.textColor = PrismPaletteProvider.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
        ])
    }

    // MARK: - Progress Header
    private func assembleProgressHeader() {
        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        progressLabel.textColor = PrismPaletteProvider.textSecondary
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        let progressBar = UIView()
        progressBar.backgroundColor = PrismPaletteProvider.cardBorder
        progressBar.layer.cornerRadius = 3
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.tag = 100
        view.addSubview(progressBar)

        let progressFill = UIView()
        progressFill.layer.cornerRadius = 3
        progressFill.tag = 101
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBar.addSubview(progressFill)

        // Gradient for fill
        let gradFill = CAGradientLayer()
        gradFill.colors = [UIColor(hex: "#FFD700").cgColor, UIColor(hex: "#FFA500").cgColor]
        gradFill.startPoint = CGPoint(x: 0, y: 0.5)
        gradFill.endPoint = CGPoint(x: 1, y: 0.5)
        gradFill.cornerRadius = 3
        progressFill.layer.insertSublayer(gradFill, at: 0)
        progressFill.clipsToBounds = true

        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressBar.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressBar.heightAnchor.constraint(equalToConstant: 6),

            progressFill.topAnchor.constraint(equalTo: progressBar.topAnchor),
            progressFill.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
        ])

        // Width constraint for fill (updated in refreshProgress)
        let fillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)
        fillWidth.isActive = true
        fillWidth.identifier = "progressFillWidth"
    }

    private func refreshProgress() {
        let vault = AchievementVault.shared
        progressLabel.text = "Unlocked \(vault.unlockedCount) / \(vault.totalCount)"

        // Update fill width
        let progressBar = view.viewWithTag(100)!
        let progressFill = view.viewWithTag(101)!
        let fraction = vault.totalCount > 0 ? CGFloat(vault.unlockedCount) / CGFloat(vault.totalCount) : 0

        view.layoutIfNeeded()
        for constraint in progressFill.constraints where constraint.identifier == "progressFillWidth" {
            constraint.constant = progressBar.bounds.width * fraction
        }

        // Update gradient frame
        if let grad = progressFill.layer.sublayers?.first as? CAGradientLayer {
            grad.frame = CGRect(x: 0, y: 0, width: progressBar.bounds.width * fraction, height: 6)
        }
    }

    // MARK: - Collection View
    private func assembleCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: AchievementCell.reuseID)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Actions
    @objc private func handleBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AchievementGalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        catalog.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AchievementCell.reuseID, for: indexPath) as! AchievementCell
        let medal = catalog[indexPath.item]
        let unlocked = AchievementVault.shared.isUnlocked(medal.id)
        cell.configure(medal: medal, isUnlocked: unlocked)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AchievementGalleryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        let spacing: CGFloat = 10
        let totalWidth = collectionView.bounds.width - inset * 2 - spacing
        let cellWidth = totalWidth / 2
        return CGSize(width: cellWidth, height: 80)
    }
}

// MARK: - Achievement Cell
private class AchievementCell: UICollectionViewCell {

    static let reuseID = "AchievementCell"

    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let captionLabel = UILabel()
    private let lockOverlay = UIView()
    private let lockIcon = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func assembleLayout() {
        contentView.backgroundColor = PrismPaletteProvider.cardBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = PrismPaletteProvider.cardBorder.cgColor
        contentView.clipsToBounds = true

        iconLabel.font = .systemFont(ofSize: 28)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = PrismPaletteProvider.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        captionLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        captionLabel.textColor = PrismPaletteProvider.textSecondary
        captionLabel.numberOfLines = 2
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(captionLabel)

        // Lock overlay
        lockOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        lockOverlay.translatesAutoresizingMaskIntoConstraints = false
        lockOverlay.isHidden = true
        contentView.addSubview(lockOverlay)

        lockIcon.text = "🔒"
        lockIcon.font = .systemFont(ofSize: 20)
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        lockOverlay.addSubview(lockIcon)

        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 34),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            captionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            captionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            lockOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            lockOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lockOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lockOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            lockIcon.centerXAnchor.constraint(equalTo: lockOverlay.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: lockOverlay.centerYAnchor),
        ])
    }

    func configure(medal: AchievementMedal, isUnlocked: Bool) {
        iconLabel.text = medal.icon
        titleLabel.text = medal.title
        captionLabel.text = medal.caption
        lockOverlay.isHidden = isUnlocked

        if isUnlocked {
            contentView.layer.borderColor = UIColor(hex: "#FFD700").withAlphaComponent(0.4).cgColor
        } else {
            contentView.layer.borderColor = PrismPaletteProvider.cardBorder.cgColor
        }
    }
}
