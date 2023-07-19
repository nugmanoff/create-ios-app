import Foundation
import UIKit
import Nivelir
import Factory

class AuthCoordinator {
    @Injected(\.navigator) var navigator
    @Injected(\.screens) var screens

    func start() {
        let route = ScreenWindowRoute()
            .setRoot(
                to: screens
                    .enterUsernameScreen()
                    .withStackContainer()
            )
            .makeKeyAndVisible()
        
        navigator.navigate(to: route)
    }

    func onEnterUsernameNextDidTap(container: UIViewController) {
        let screen = AuthEnterPasswordViewController()
        navigator.navigate(from: container) { route in
            route
                .stack
                .push(screen)
        }

    }

    func onEnterPasswordNextDidTap(container: UIViewController) {
        navigator.navigate(from: container) { route in
            route
                .stack
                .clear(animation: .crossDissolve)
                .push(screens.homeScreen(), animation: .crossDissolve)
        }
    }
}
