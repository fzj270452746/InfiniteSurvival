//
//  FeedbackFX.swift
//  InfiniteSurvival
//
//  Centralized lightweight sound and haptic helpers.
//

import UIKit
import AVFoundation

final class FeedbackFX {
    static let shared = FeedbackFX()
    private init() { prepare() }

    private var playerCache: [String: AVAudioPlayer] = [:]
    private var hapticsEnabled: Bool { UserDefaults.standard.bool(forKey: SettingsKeys.hapticsOn) }
    private var soundEnabled: Bool { UserDefaults.standard.bool(forKey: SettingsKeys.soundOn) }

    func prepare() {
        // Register sensible defaults so effects are enabled out of the box
        UserDefaults.standard.register(defaults: [SettingsKeys.soundOn: true, SettingsKeys.hapticsOn: true])
        // Preload light system sounds if any bundled later
    }

    func play(_ name: String) {
        guard soundEnabled else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        if let cached = playerCache[name] {
            cached.currentTime = 0
            cached.play()
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            playerCache[name] = player
        } catch { }
    }

    func tapLight() {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func tapSuccess() {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func tapError() {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

enum SettingsKeys {
    static let soundOn = "is_settings_sound_on"
    static let hapticsOn = "is_settings_haptics_on"
}
