# BoosterKit Demo App

[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2018.0+-blue.svg)](https://developer.apple.com/ios/)
[![BoosterKit](https://img.shields.io/badge/BoosterKit-Package-brightgreen.svg)](https://github.com/Different-Productions/BoosterKit)

A demonstration iOS app showcasing [BoosterKit](https://github.com/Different-Productions/BoosterKit) integration and features.

## What This Demonstrates

This demo app shows how to:
- Integrate BoosterKit into an iOS app
- Display one-time feature announcement modals
- Customize Booster content with images, titles, and descriptions
- Add custom UIViews to Boosters for rich, interactive content
- Configure sheet detents (medium, large, custom)
- Track viewed Boosters with SwiftData
- Handle user interactions (primary action vs dismissal)
- Load Boosters from JSON configuration

## Features Demonstrated

- **App Launch Flow**: See Boosters appear automatically after app launch
- **Custom Views**: Gradient background with rocket emoji and custom text
- **Sheet Detents**: Medium and large sheet sizes that users can expand
- **Priority System**: Multiple Boosters with different priority levels
- **Session Management**: Only one Booster shown per app session
- **User Actions**: Handle button taps and dismissals
- **Reset Functionality**: Test button to reset viewed state for development

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Different-Productions/BoosterKitDemo.git
cd BoosterKitDemo
```

### 2. Open in Xcode

```bash
open BoosterKitDemo.xcodeproj
```

### 3. Run the App

- Select an iOS 18.0+ simulator or device
- Press `Cmd+R` to build and run
- Watch for the Booster modal to appear after launch

## Project Structure

```
BoosterKitDemo/
├── BoosterKitDemo/
│   ├── AppDelegate.swift        # SwiftData setup
│   ├── SceneDelegate.swift      # BoosterManager initialization
│   ├── MainViewController.swift # Demo UI with reset button
│   └── boosters.json           # Booster configuration
```

## Code Examples

### SwiftData Setup (AppDelegate.swift)

```swift
var modelContainer: ModelContainer?

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  let schema = Schema([BoosterViewRecord.self])
  let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
  modelContainer = try ModelContainer(for: schema, configurations: [config])
  return true
}
```

### BoosterManager Integration (SceneDelegate.swift)

```swift
// Create custom view configurations
let viewConfigurations = createViewConfigurations()

boosterManager = BoosterManager(
  modelContainer: modelContainer,
  boosters: loadBoosters(),
  viewConfigurations: viewConfigurations
) { userAction in
  switch userAction {
  case .primaryActionTapped(let boosterID):
    print("User tapped primary action for: \(boosterID)")
  case .dismissed(let boosterID):
    print("User dismissed: \(boosterID)")
  }
}

// Show Booster after brief delay
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
  self.boosterManager?.showBoosterIfNeeded(from: rootVC)
}
```

### Custom View Configuration

```swift
func createViewConfigurations() -> [String: BoosterViewConfiguration] {
  var configurations: [String: BoosterViewConfiguration] = [:]

  // Create custom view with gradient background
  let customView = createCustomWelcomeView()
  configurations["welcome_booster"] = BoosterViewConfiguration(
    customView: customView,
    customViewHeight: 120,
    detents: [.medium(), .large()]  // Allow user to expand sheet
  )

  return configurations
}

func createCustomWelcomeView() -> UIView {
  let containerView = UIView()
  containerView.backgroundColor = .systemIndigo.withAlphaComponent(0.1)
  containerView.layer.cornerRadius = 12

  // Add gradient layer
  let gradientLayer = CAGradientLayer()
  gradientLayer.colors = [
    UIColor.systemIndigo.withAlphaComponent(0.3).cgColor,
    UIColor.systemPurple.withAlphaComponent(0.3).cgColor
  ]
  containerView.layer.insertSublayer(gradientLayer, at: 0)

  // Add content (emoji + text)
  // ... see SceneDelegate.swift for full implementation

  return containerView
}
```

### Booster Configuration (boosters.json)

```json
[
  {
    "id": "welcome_v1",
    "title": "Welcome to BoosterKit Demo!",
    "description": "This demo showcases how to integrate BoosterKit into your iOS app.",
    "imageName": "star.circle.fill",
    "buttonText": "Get Started",
    "priority": 10
  }
]
```

## Testing the Demo

1. **First Launch**: Highest priority Booster appears
2. **Tap "Continue"**: Booster is marked as viewed
3. **Close App**: Reopen to see if another Booster appears
4. **Tap "Reset Viewed Boosters"**: Clear viewed state to test again

## Learn More

- [BoosterKit Package](https://github.com/Different-Productions/BoosterKit)
- [Package Documentation](https://github.com/Different-Productions/BoosterKit#readme)
- [Report Issues](https://github.com/Different-Productions/BoosterKit/issues)

## License

This demo app is provided as-is for demonstration purposes. BoosterKit itself is available under the MIT license.

## Questions?

Check out the [BoosterKit Package Documentation](https://github.com/Different-Productions/BoosterKit#readme) for detailed integration guides and API reference.
