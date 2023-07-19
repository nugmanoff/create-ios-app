@_exported import Inject
import Convenience
import UIKit
import PulseUI
import Nivelir

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupNavigation()
        return true
    }
    
    private func setupNavigation() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let container = AppContainer.shared
        
        self.window = window
        
        container.navigator.register {
            ScreenNavigator(window: window)
        }
        
        container.appCoordinator().start()
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
