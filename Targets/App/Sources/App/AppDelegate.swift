@_exported import Inject
import Resources
import Infra
import UIKit
import PulseUI
import SideMenu

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private var services: Services?
    private var screens: AppScreens?
    
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupWindow()
        return true
    }
    
    private func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let services = Services(window: window)
        let screens = AppScreens(services: services)

        self.window = window
        self.services = services
        self.screens = screens

        services
            .screenNavigator()
            .navigate(to: screens.showHomeRoute())
    }
}

extension UIViewController {
func topMostViewController() -> UIViewController {
    if presentedViewController == nil {
        return self
    }
    if let navigationViewController = presentedViewController as? UINavigationController {
        if let visibleViewController = navigationViewController.visibleViewController {
            return visibleViewController.topMostViewController()
        } else {
            return navigationViewController
        }
    }
    if let tabBarViewController = presentedViewController as? UITabBarController {
        if let selectedViewController = tabBarViewController.selectedViewController {
            return selectedViewController.topMostViewController()
        }
        return tabBarViewController.topMostViewController()
    }
    return presentedViewController!.topMostViewController()
}
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        UIApplication.shared.windows.filter(\.isKeyWindow).first?.rootViewController?.topMostViewController()
    }
}

#if DEBUG
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            if let topVC = UIApplication.shared.topMostViewController(), !(topVC is PulseUI.MainViewController) {
                topVC.present(PulseUI.MainViewController(), animated: true, completion: nil)
            }
        }
    }
}
#endif
