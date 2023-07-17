import UIKit

public extension UIViewController {
    class var identifier: String {
        String(describing: self)
    }

    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func add(_ child: UIViewController, to view: UIView, stickingToEdges: Bool = true) {
        addChild(child)
        if stickingToEdges {
            view.addSubviewStickingToEdges(child.view)
        } else {
            view.addSubview(child.view)
        }
        child.didMove(toParent: self)
    }
    
    func addIgnoringSafeArea(_ bridgedView: BridgedView) {
        add(bridgedView)
        bridgedView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bridgedView.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            bridgedView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bridgedView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            bridgedView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
    }
    
    func addIgnoringSafeArea(_ bridgedView: BridgedView, to view: UIView) {
        addChild(bridgedView)
        view.addSubview(bridgedView.view)
        bridgedView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bridgedView.view.topAnchor.constraint(equalTo: view.topAnchor),
            bridgedView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bridgedView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            bridgedView.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    func addBridgedViewAsRoot(_ bridgedView: BridgedView, topToSafeAreaLayoutGuide: Bool = true) {
        add(bridgedView)
        bridgedView.view.translatesAutoresizingMaskIntoConstraints = false
        let topAnchor = topToSafeAreaLayoutGuide ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor
        NSLayoutConstraint.activate([
            bridgedView.view.topAnchor.constraint(equalTo: topAnchor),
            bridgedView.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            bridgedView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            bridgedView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
    }
    
    func remove(childController: UIViewController) {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }

    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
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

public extension UIApplication {
    func topMostViewController() -> UIViewController? {
        UIApplication.shared.windows.filter(\.isKeyWindow).first?.rootViewController?.topMostViewController()
    }
}
