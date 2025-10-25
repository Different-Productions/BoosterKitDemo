import UIKit
import BoosterKit

class MainViewController: UIViewController {

    private let titleLabel = UILabel()
    private let instructionLabel = UILabel()
    private let resetButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "BoosterKit Demo"
        view.backgroundColor = .systemBackground

        setupUI()
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

            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
