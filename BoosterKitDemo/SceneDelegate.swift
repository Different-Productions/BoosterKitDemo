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

        // Initialize BoosterManager with boosters
        boosterManager = BoosterManager(modelContainer: modelContainer, boosters: boosters) { userAction in
            switch userAction {
            case .primaryActionTapped(let boosterID):
                print("User tapped action for booster: \(boosterID)")
                self.handleBoosterAction(boosterID: boosterID)

            case .dismissed(let boosterID):
                print("User dismissed booster: \(boosterID)")
            }
        }

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
