import UIKit
import BoosterKit

class MainViewController: UIViewController {

    private let titleLabel = UILabel()
    private let instructionLabel = UILabel()
    private let devModeContainer = UIView()
    private let devModeLabel = UILabel()
    private let devModeSwitch = UISwitch()
    private let devModeInfoLabel = UILabel()
    private let resetButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "BoosterKit Demo"
        view.backgroundColor = .systemBackground

        setupUI()
        loadDevModeState()
    }

    private func setupUI() {
        // Configure title label
        titleLabel.text = "BoosterKit Demo App"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Configure instruction label
        instructionLabel.text = "A Booster should appear when you launch the app for the first time.\n\nOnce you've seen it, it won't show again. Tap the button below to reset and see it again."
        instructionLabel.font = .systemFont(ofSize: 16)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        // Configure dev mode container
        devModeContainer.backgroundColor = .systemGray6
        devModeContainer.layer.cornerRadius = 12
        devModeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(devModeContainer)

        // Configure dev mode label
        devModeLabel.text = "Dev Mode"
        devModeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        devModeLabel.translatesAutoresizingMaskIntoConstraints = false
        devModeContainer.addSubview(devModeLabel)

        // Configure dev mode switch
        devModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        devModeSwitch.addTarget(self, action: #selector(devModeSwitchChanged), for: .valueChanged)
        devModeContainer.addSubview(devModeSwitch)

        // Configure dev mode info label
        devModeInfoLabel.text = "When enabled, boosters won't be marked as viewed and can be shown repeatedly"
        devModeInfoLabel.font = .systemFont(ofSize: 13)
        devModeInfoLabel.textAlignment = .left
        devModeInfoLabel.numberOfLines = 0
        devModeInfoLabel.textColor = .secondaryLabel
        devModeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        devModeContainer.addSubview(devModeInfoLabel)

        // Configure reset button
        resetButton.setTitle("Reset Demo (Clear Viewed Boosters)", for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        resetButton.backgroundColor = .systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 12
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        view.addSubview(resetButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            devModeContainer.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 32),
            devModeContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            devModeContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            devModeLabel.topAnchor.constraint(equalTo: devModeContainer.topAnchor, constant: 16),
            devModeLabel.leadingAnchor.constraint(equalTo: devModeContainer.leadingAnchor, constant: 16),

            devModeSwitch.centerYAnchor.constraint(equalTo: devModeLabel.centerYAnchor),
            devModeSwitch.trailingAnchor.constraint(equalTo: devModeContainer.trailingAnchor, constant: -16),
            devModeSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: devModeLabel.trailingAnchor, constant: 16),

            devModeInfoLabel.topAnchor.constraint(equalTo: devModeLabel.bottomAnchor, constant: 8),
            devModeInfoLabel.leadingAnchor.constraint(equalTo: devModeContainer.leadingAnchor, constant: 16),
            devModeInfoLabel.trailingAnchor.constraint(equalTo: devModeContainer.trailingAnchor, constant: -16),
            devModeInfoLabel.bottomAnchor.constraint(equalTo: devModeContainer.bottomAnchor, constant: -16),

            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func devModeSwitchChanged() {
        let isDevMode = devModeSwitch.isOn
        UserDefaults.standard.set(isDevMode, forKey: "isDevMode")

        let alert = UIAlertController(
            title: "Dev Mode \(isDevMode ? "Enabled" : "Disabled")",
            message: "Restart the app for this change to take effect.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func loadDevModeState() {
        let isDevMode = UserDefaults.standard.bool(forKey: "isDevMode")
        devModeSwitch.isOn = isDevMode
    }

    @objc private func resetButtonTapped() {
        let alert = UIAlertController(
            title: "Reset Demo?",
            message: "This will clear all viewed Booster records. Restart the app to see the Booster again.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.clearViewedBoosters()
        })

        present(alert, animated: true)
    }

    private func clearViewedBoosters() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let modelContainer = appDelegate.modelContainer else {
            return
        }

        Task {
            do {
                let storage = BoosterStorage(modelContainer: modelContainer)
                // Clear all viewed records
                let viewedIDs = try await storage.getViewedBoosterIDs()
                for id in viewedIDs {
                    try await storage.removeViewRecord(boosterID: id)
                }

                await MainActor.run {
                    let successAlert = UIAlertController(
                        title: "Reset Complete",
                        message: "All viewed Booster records have been cleared. Restart the app to see the Booster again.",
                        preferredStyle: .alert
                    )
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(successAlert, animated: true)
                }
            } catch {
                print("Error clearing viewed boosters: \(error)")
            }
        }
    }
}
