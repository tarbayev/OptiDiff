import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    let animationSpeed = UserDefaults.standard.float(forKey: "AnimationSpeed")
    if animationSpeed > 0 {
      window?.layer.speed = animationSpeed
    }
    return true
  }
}
