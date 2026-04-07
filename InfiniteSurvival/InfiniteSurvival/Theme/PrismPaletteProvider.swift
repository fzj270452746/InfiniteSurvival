//
//  PrismPaletteProvider.swift
//  InfiniteSurvival
//
//  Color and styling constants
//

import UIKit

struct PrismPaletteProvider {

    // MARK: - Main Theme Colors
    static let canvasBackdrop = UIColor(hex: "#1A1A2E")
    static let panelSurface = UIColor(hex: "#16213E")
    static let accentEmber = UIColor(hex: "#E94560")
    static let accentAurora = UIColor(hex: "#0F3460")
    static let accentLuminance = UIColor(hex: "#533483")
    static let textPrimary = UIColor(hex: "#EAEAEA")
    static let textSecondary = UIColor(hex: "#A0A0B8")
    static let textMuted = UIColor(hex: "#6B6B80")

    // MARK: - Vitality Colors
    static let healthCrimson = UIColor(hex: "#FF4757")
    static let healthCrimsonDim = UIColor(hex: "#FF475730")
    static let foodEmerald = UIColor(hex: "#2ED573")
    static let foodEmeraldDim = UIColor(hex: "#2ED57330")
    static let staminaCobalt = UIColor(hex: "#1E90FF")
    static let staminaCobaltDim = UIColor(hex: "#1E90FF30")

    // MARK: - Tile Colors
    static let bambooTint = UIColor(hex: "#00B894")
    static let characterTint = UIColor(hex: "#FDCB6E")
    static let circleTint = UIColor(hex: "#6C5CE7")
    static let specialTint = UIColor(hex: "#FD79A8")

    // MARK: - Button Colors
    static let buttonPrimary = UIColor(hex: "#E94560")
    static let buttonSecondary = UIColor(hex: "#0F3460")
    static let buttonAccent = UIColor(hex: "#533483")
    static let buttonDisabled = UIColor(hex: "#3A3A55")

    // MARK: - Card / Surface
    static let cardBackground = UIColor(hex: "#1E2545")
    static let cardBorder = UIColor(hex: "#2A3060")
    static let overlayDim = UIColor(hex: "#000000AA")

    // MARK: - Gradient Presets
    static var heroGradientColors: [CGColor] {
        return [
            UIColor(hex: "#0F0C29").cgColor,
            UIColor(hex: "#302B63").cgColor,
            UIColor(hex: "#24243E").cgColor
        ]
    }

    static var sunsetGradientColors: [CGColor] {
        return [
            UIColor(hex: "#FC466B").cgColor,
            UIColor(hex: "#3F5EFB").cgColor
        ]
    }

    static var emeraldGradientColors: [CGColor] {
        return [
            UIColor(hex: "#11998E").cgColor,
            UIColor(hex: "#38EF7D").cgColor
        ]
    }

    // MARK: - Suit Color Lookup
    static func tintForSuit(_ suit: VesselSuitKind) -> UIColor {
        switch suit {
        case .bamboo:    return bambooTint
        case .character: return characterTint
        case .circle:    return circleTint
        case .special:   return specialTint
        }
    }

    // MARK: - Adaptive Sizing
    static func proportionalWidth(_ ratio: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.width * ratio
    }

    static func proportionalHeight(_ ratio: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.height * ratio
    }

    static var isCompactDevice: Bool {
        return UIScreen.main.bounds.height < 700
    }
}

// MARK: - UIColor Hex Extension
extension UIColor {
    convenience init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized = sanitized.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgbValue)

        let length = sanitized.count
        if length == 8 {
            self.init(
                red: CGFloat((rgbValue >> 24) & 0xFF) / 255.0,
                green: CGFloat((rgbValue >> 16) & 0xFF) / 255.0,
                blue: CGFloat((rgbValue >> 8) & 0xFF) / 255.0,
                alpha: CGFloat(rgbValue & 0xFF) / 255.0
            )
        } else {
            self.init(
                red: CGFloat((rgbValue >> 16) & 0xFF) / 255.0,
                green: CGFloat((rgbValue >> 8) & 0xFF) / 255.0,
                blue: CGFloat(rgbValue & 0xFF) / 255.0,
                alpha: 1.0
            )
        }
    }
}
