//
//  EtherealDialogOverlay.swift
//  InfiniteSurvival
//
//  Custom modal dialog with glass morphism effect
//

import UIKit

class EtherealDialogOverlay: UIView {

    // MARK: - Subviews
    private let backdropBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let contentCard = UIView()
    private let titleBanner = UILabel()
    private let bodyNarrative = UILabel()
    private let iconContainer = UIView()
    private let iconLabel = UILabel()
    private let actionStack = UIStackView()
    private let decorativeLine = UIView()

    // MARK: - Callbacks
    private var primaryAction: (() -> Void)?
    private var secondaryAction: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleStructure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleStructure()
    }

    // MARK: - Assembly
    private func assembleStructure() {
        backgroundColor = .clear
        isHidden = true

        // Backdrop
        backdropBlur.frame = bounds
        backdropBlur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backdropBlur.alpha = 0
        addSubview(backdropBlur)

        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap))
        backdropBlur.addGestureRecognizer(tapDismiss)

        // Content Card
        contentCard.backgroundColor = PrismPaletteProvider.cardBackground
        contentCard.layer.cornerRadius = 20
        contentCard.layer.borderWidth = 1
        contentCard.layer.borderColor = PrismPaletteProvider.cardBorder.cgColor
        contentCard.layer.shadowColor = UIColor.black.cgColor
        contentCard.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentCard.layer.shadowRadius = 30
        contentCard.layer.shadowOpacity = 0.5
        contentCard.translatesAutoresizingMaskIntoConstraints = false
        contentCard.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        contentCard.alpha = 0
        addSubview(contentCard)

        // Icon Container
        iconContainer.backgroundColor = PrismPaletteProvider.accentEmber.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 30
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(iconContainer)

        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconLabel)

        // Decorative Line
        decorativeLine.translatesAutoresizingMaskIntoConstraints = false
        let lineGradient = CAGradientLayer()
        lineGradient.colors = PrismPaletteProvider.sunsetGradientColors
        lineGradient.startPoint = CGPoint(x: 0, y: 0.5)
        lineGradient.endPoint = CGPoint(x: 1, y: 0.5)
        decorativeLine.layer.addSublayer(lineGradient)
        contentCard.addSubview(decorativeLine)

        // Title
        titleBanner.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleBanner.textColor = PrismPaletteProvider.textPrimary
        titleBanner.textAlignment = .center
        titleBanner.numberOfLines = 0
        titleBanner.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(titleBanner)

        // Body
        bodyNarrative.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bodyNarrative.textColor = PrismPaletteProvider.textSecondary
        bodyNarrative.textAlignment = .center
        bodyNarrative.numberOfLines = 0
        bodyNarrative.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(bodyNarrative)

        // Action Stack
        actionStack.axis = .horizontal
        actionStack.spacing = 12
        actionStack.distribution = .fillEqually
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(actionStack)

        let horizontalPadding: CGFloat = 24

        NSLayoutConstraint.activate([
            contentCard.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentCard.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentCard.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.82),

            iconContainer.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 24),
            iconContainer.centerXAnchor.constraint(equalTo: contentCard.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 60),
            iconContainer.heightAnchor.constraint(equalToConstant: 60),

            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            decorativeLine.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16),
            decorativeLine.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: horizontalPadding),
            decorativeLine.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -horizontalPadding),
            decorativeLine.heightAnchor.constraint(equalToConstant: 2),

            titleBanner.topAnchor.constraint(equalTo: decorativeLine.bottomAnchor, constant: 16),
            titleBanner.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: horizontalPadding),
            titleBanner.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -horizontalPadding),

            bodyNarrative.topAnchor.constraint(equalTo: titleBanner.bottomAnchor, constant: 10),
            bodyNarrative.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: horizontalPadding),
            bodyNarrative.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -horizontalPadding),

            actionStack.topAnchor.constraint(equalTo: bodyNarrative.bottomAnchor, constant: 24),
            actionStack.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: horizontalPadding),
            actionStack.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -horizontalPadding),
            actionStack.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -24),
            actionStack.heightAnchor.constraint(equalToConstant: 46),
        ])
    }

    // MARK: - Configuration
    func presentDialog(
        icon: String,
        tintColor: UIColor,
        title: String,
        body: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil,
        onPrimary: @escaping () -> Void,
        onSecondary: (() -> Void)? = nil
    ) {
        iconLabel.text = icon
        iconContainer.backgroundColor = tintColor.withAlphaComponent(0.15)
        titleBanner.text = title
        bodyNarrative.text = body
        primaryAction = onPrimary
        secondaryAction = onSecondary

        // Clear existing buttons
        actionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Primary button
        let primaryBtn = LuminousActionButton()
        primaryBtn.setTitle(primaryButtonTitle, for: .normal)
        primaryBtn.applyGradientScheme(startColor: tintColor, endColor: tintColor.withAlphaComponent(0.6))
        primaryBtn.addTarget(self, action: #selector(handlePrimaryTap), for: .touchUpInside)
        actionStack.addArrangedSubview(primaryBtn)

        // Secondary button
        if let secondaryTitle = secondaryButtonTitle {
            let secondaryBtn = LuminousActionButton()
            secondaryBtn.setTitle(secondaryTitle, for: .normal)
            secondaryBtn.applyGradientScheme(
                startColor: PrismPaletteProvider.buttonSecondary,
                endColor: PrismPaletteProvider.accentAurora
            )
            secondaryBtn.addTarget(self, action: #selector(handleSecondaryTap), for: .touchUpInside)
            actionStack.addArrangedSubview(secondaryBtn)
        }

        // Animate in
        isHidden = false
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.backdropBlur.alpha = 1
            self.contentCard.transform = .identity
            self.contentCard.alpha = 1
        }
    }

    func concealDialog(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.backdropBlur.alpha = 0
            self.contentCard.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.contentCard.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }

    // MARK: - Actions
    @objc private func handlePrimaryTap() {
        concealDialog { [weak self] in
            self?.primaryAction?()
        }
    }

    @objc private func handleSecondaryTap() {
        concealDialog { [weak self] in
            self?.secondaryAction?()
        }
    }

    @objc private func handleBackdropTap() {
        // No dismiss on backdrop tap for game dialogs
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update decorative line gradient
        if let gradientLayer = decorativeLine.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = decorativeLine.bounds
        }
    }
}
