//
//  RadiantGaugeStrip.swift
//  InfiniteSurvival
//
//  Animated status bar for health/food/stamina
//

import UIKit

class RadiantGaugeStrip: UIView {

    // MARK: - Subviews
    private let progressFillLayer = CAGradientLayer()
    private let iconEmblemLabel = UILabel()
    private let numericReadout = UILabel()
    private let captionLabel = UILabel()
    private let shimmerLayer = CAGradientLayer()
    private let containerTrack = UIView()

    // MARK: - Configuration
    private var filledFraction: CGFloat = 1.0
    private var primaryTint: UIColor = PrismPaletteProvider.healthCrimson
    private var dimTint: UIColor = PrismPaletteProvider.healthCrimsonDim

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleSubviews()
    }

    // MARK: - Setup
    private func assembleSubviews() {
        backgroundColor = .clear

        // Icon
        iconEmblemLabel.font = UIFont.systemFont(ofSize: 14)
        iconEmblemLabel.textAlignment = .center
        iconEmblemLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconEmblemLabel)

        // Caption
        captionLabel.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        captionLabel.textColor = PrismPaletteProvider.textSecondary
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)

        // Track
        containerTrack.backgroundColor = PrismPaletteProvider.panelSurface
        containerTrack.layer.cornerRadius = 4
        containerTrack.clipsToBounds = true
        containerTrack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerTrack)

        // Progress fill
        progressFillLayer.cornerRadius = 4
        progressFillLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressFillLayer.endPoint = CGPoint(x: 1, y: 0.5)
        containerTrack.layer.addSublayer(progressFillLayer)

        // Numeric readout
        numericReadout.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        numericReadout.textColor = PrismPaletteProvider.textPrimary
        numericReadout.textAlignment = .right
        numericReadout.translatesAutoresizingMaskIntoConstraints = false
        addSubview(numericReadout)

        NSLayoutConstraint.activate([
            iconEmblemLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconEmblemLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconEmblemLabel.widthAnchor.constraint(equalToConstant: 20),

            captionLabel.leadingAnchor.constraint(equalTo: iconEmblemLabel.trailingAnchor, constant: 4),
            captionLabel.topAnchor.constraint(equalTo: topAnchor),

            containerTrack.leadingAnchor.constraint(equalTo: iconEmblemLabel.trailingAnchor, constant: 4),
            containerTrack.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 2),
            containerTrack.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerTrack.heightAnchor.constraint(equalToConstant: 8),

            numericReadout.leadingAnchor.constraint(equalTo: containerTrack.trailingAnchor, constant: 6),
            numericReadout.trailingAnchor.constraint(equalTo: trailingAnchor),
            numericReadout.centerYAnchor.constraint(equalTo: centerYAnchor),
            numericReadout.widthAnchor.constraint(equalToConstant: 42),
        ])
    }

    // MARK: - Configuration
    func configureAppearance(icon: String, label: String, tint: UIColor, dimTint: UIColor) {
        iconEmblemLabel.text = icon
        captionLabel.text = label.uppercased()
        self.primaryTint = tint
        self.dimTint = dimTint
        containerTrack.backgroundColor = dimTint

        progressFillLayer.colors = [
            tint.cgColor,
            tint.withAlphaComponent(0.7).cgColor
        ]
    }

    // MARK: - Update
    func refreshGauge(currentValue: Int, maximumValue: Int, animated: Bool = true) {
        let fraction = CGFloat(currentValue) / CGFloat(max(1, maximumValue))
        self.filledFraction = fraction
        numericReadout.text = "\(currentValue)/\(maximumValue)"

        if animated {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        } else {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let trackBounds = containerTrack.bounds
        let fillWidth = trackBounds.width * filledFraction
        progressFillLayer.frame = CGRect(x: 0, y: 0, width: fillWidth, height: trackBounds.height)
    }
}
