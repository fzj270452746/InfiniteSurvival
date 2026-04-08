import UIKit

final class SettingsViewController: UIViewController {
    private let soundSwitch = UISwitch()
    private let hapticSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PrismPaletteProvider.panelSurface.withAlphaComponent(0.95)

        let title = UILabel()
        title.text = "Settings"
        title.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        title.textColor = PrismPaletteProvider.textPrimary
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        let soundRow = row(title: "Sound Effects", control: soundSwitch)
        let hapticRow = row(title: "Haptics", control: hapticSwitch)

        let stack = UIStackView(arrangedSubviews: [soundRow, hapticRow])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        soundSwitch.isOn = UserDefaults.standard.object(forKey: SettingsKeys.soundOn) as? Bool ?? true
        hapticSwitch.isOn = UserDefaults.standard.object(forKey: SettingsKeys.hapticsOn) as? Bool ?? true
        UserDefaults.standard.register(defaults: [SettingsKeys.soundOn: true, SettingsKeys.hapticsOn: true])

        soundSwitch.addTarget(self, action: #selector(toggled), for: .valueChanged)
        hapticSwitch.addTarget(self, action: #selector(toggled), for: .valueChanged)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    private func row(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.textColor = PrismPaletteProvider.textPrimary
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        let container = UIStackView(arrangedSubviews: [label, control])
        container.axis = .horizontal
        container.distribution = .equalSpacing
        return container
    }

    @objc private func toggled() {
        UserDefaults.standard.set(soundSwitch.isOn, forKey: SettingsKeys.soundOn)
        UserDefaults.standard.set(hapticSwitch.isOn, forKey: SettingsKeys.hapticsOn)
    }
}

