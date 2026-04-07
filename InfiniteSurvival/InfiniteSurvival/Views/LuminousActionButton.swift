//
//  LuminousActionButton.swift
//  InfiniteSurvival
//
//  Stylish custom game button
//

import UIKit

class LuminousActionButton: UIButton {

    // MARK: - Layers
    private let gradientBackdrop = CAGradientLayer()
    private let glowEffectLayer = CALayer()

    // MARK: - State
    private var originalTransform: CGAffineTransform = .identity

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleVisuals()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleVisuals()
    }

    // MARK: - Setup
    private func assembleVisuals() {
        layer.cornerRadius = 12
        clipsToBounds = false

        // Glow
        glowEffectLayer.shadowColor = PrismPaletteProvider.accentEmber.cgColor
        glowEffectLayer.shadowOffset = .zero
        glowEffectLayer.shadowRadius = 8
        glowEffectLayer.shadowOpacity = 0.4
        layer.insertSublayer(glowEffectLayer, at: 0)

        // Gradient
        gradientBackdrop.cornerRadius = 12
        gradientBackdrop.startPoint = CGPoint(x: 0, y: 0)
        gradientBackdrop.endPoint = CGPoint(x: 1, y: 1)
        gradientBackdrop.colors = [
            PrismPaletteProvider.buttonPrimary.cgColor,
            PrismPaletteProvider.accentLuminance.cgColor
        ]
        layer.insertSublayer(gradientBackdrop, at: 0)

        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        setTitleColor(PrismPaletteProvider.textPrimary, for: .normal)
        setTitleColor(PrismPaletteProvider.textMuted, for: .disabled)

        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchRelease), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Theming
    func applyGradientScheme(startColor: UIColor, endColor: UIColor) {
        gradientBackdrop.colors = [startColor.cgColor, endColor.cgColor]
        glowEffectLayer.shadowColor = startColor.cgColor
    }

    // MARK: - Touch Feedback
    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            self.alpha = 0.85
        }
    }

    @objc private func handleTouchRelease() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }

    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                gradientBackdrop.opacity = 1.0
                glowEffectLayer.shadowOpacity = 0.4
            } else {
                gradientBackdrop.opacity = 0.4
                glowEffectLayer.shadowOpacity = 0
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBackdrop.frame = bounds
        glowEffectLayer.frame = bounds
        glowEffectLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }
}
