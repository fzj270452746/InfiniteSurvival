//
//  ArcaneNotificationBanner.swift
//  InfiniteSurvival
//
//  Floating notification for turn events
//

import UIKit

class ArcaneNotificationBanner: UIView {

    private let contentLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconLabel = UILabel()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleVisuals()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleVisuals()
    }

    private func assembleVisuals() {
        layer.cornerRadius = 14
        clipsToBounds = true
        alpha = 0

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = PrismPaletteProvider.sunsetGradientColors
        layer.insertSublayer(gradientLayer, at: 0)

        iconLabel.font = UIFont.systemFont(ofSize: 20)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)

        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        contentLabel.textColor = .white
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentLabel)

        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            contentLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 10),
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            subtitleLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    func flashBanner(icon: String, title: String, subtitle: String, colors: [CGColor]? = nil, duration: TimeInterval = 2.0) {
        iconLabel.text = icon
        contentLabel.text = title
        subtitleLabel.text = subtitle

        if let customColors = colors {
            gradientLayer.colors = customColors
        }

        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.88, height: 60)

        transform = CGAffineTransform(translationX: 0, y: -20)
        alpha = 0

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
            self.alpha = 1
            self.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: []) {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: -20)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
