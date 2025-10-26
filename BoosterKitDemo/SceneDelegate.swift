import UIKit
import SwiftData
import BoosterKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var boosterManager: BoosterManager?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Get model container from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let modelContainer = appDelegate.modelContainer else {
            fatalError("ModelContainer not configured")
        }

        // Create window
        window = UIWindow(windowScene: windowScene)

        // Setup root view controller
        let mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        // Load boosters from JSON file
        let boosters = loadBoosters()

        // Create custom view configurations
        let viewConfigurations = createViewConfigurations()

        // Get dev mode state from UserDefaults
        let isDevMode = UserDefaults.standard.bool(forKey: "isDevMode")

        // Initialize BoosterManager with boosters and view configurations
        boosterManager = BoosterManager(
            modelContainer: modelContainer,
            boosters: boosters,
            viewConfigurations: viewConfigurations,
            userActionHandler: { userAction in
                switch userAction {
                case .primaryActionTapped(let boosterID):
                    print("User tapped action for booster: \(boosterID)")
                    self.handleBoosterAction(boosterID: boosterID)

                case .dismissed(let boosterID):
                    print("User dismissed booster: \(boosterID)")
                }
            },
            isDevMode: isDevMode
        )

        // Show Booster after a brief delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.boosterManager?.showBoosterIfNeeded(from: navigationController)
        }
    }

    private func loadBoosters() -> [Booster] {
        // Load boosters from JSON file in the app bundle
        guard let url = Bundle.main.url(forResource: "boosters", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let boosters = try? JSONDecoder().decode([Booster].self, from: data) else {
            print("Failed to load boosters.json, using fallback boosters")
            return getFallbackBoosters()
        }

        print("Successfully loaded \(boosters.count) boosters from JSON")
        return boosters
    }

    private func getFallbackBoosters() -> [Booster] {
        // Fallback boosters if JSON loading fails
        return [
            Booster(
                id: "welcome_booster",
                title: "Welcome to BoosterKit!",
                description: "Discover how easy it is to showcase new features and updates to your users.",
                imageName: "star.circle.fill",
                buttonText: "Get Started",
                priority: 10
            ),
            Booster(
                id: "feature_update",
                title: "New Features Available",
                description: "Check out the latest updates and improvements we've made.",
                imageName: "sparkles",
                buttonText: "Learn More",
                priority: 5
            )
        ]
    }

    private func createViewConfigurations() -> [String: BoosterViewConfiguration] {
        var configurations: [String: BoosterViewConfiguration] = [:]

        // Create a custom view for the welcome booster
        let customView = createCustomWelcomeView()
        configurations["welcome_booster"] = BoosterViewConfiguration(
            customView: customView,
            customViewHeight: 120,
            detents: [.medium(), .large()]
        )

        return configurations
    }

    private func createCustomWelcomeView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemIndigo.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 12

        // Create a gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemIndigo.withAlphaComponent(0.3).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 12
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        // Add emoji and text
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let emojiLabel = UILabel()
        emojiLabel.text = "🚀"
        emojiLabel.font = .systemFont(ofSize: 48)

        let textLabel = UILabel()
        textLabel.text = "Custom View Support!\nYou can add any UIView here."
        textLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        textLabel.numberOfLines = 0
        textLabel.textColor = .systemIndigo

        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(textLabel)

        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        // Update gradient frame when layout changes
        DispatchQueue.main.async {
            gradientLayer.frame = containerView.bounds
        }

        return containerView
    }

    private func handleBoosterAction(boosterID: String) {
        // Handle navigation based on boosterID
        switch boosterID {
        case "welcome_booster":
            print("Navigate to welcome screen")
        case "feature_update_v2":
            print("Navigate to editor")
        case "settings_reminder":
            print("Navigate to settings")
        default:
            break
        }
    }
}
