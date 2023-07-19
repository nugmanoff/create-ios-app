import UIKit
import Nivelir
import SideMenu
import Factory

struct MenuScreen: Screen {
    @Injected(\.routes) var routes
    
    func build(navigator: ScreenNavigator) -> UINavigationController {
        let view = MenuViewController(
            onEditProfileDidTap: {
                navigator.navigate(to: routes.showEditProfileRoute())
            },
            onStocksListDidTap: {
                navigator.navigate(to: routes.showStocksListRoute())
            }
        )
        let menu = SideMenuNavigationController(rootViewController: view)
//        SideMenuManager.default.leftMenuNavigationController = menu
        menu.presentationStyle = .menuSlideIn
        return menu
    }
}

public struct ScreenSetupSideMenuGestureAction<
    New: Screen,
    Container: UINavigationController
>: ScreenAction where New.Container: UIViewController {

    public typealias Output = New.Container

    public let screen: New

    public init(screen: New) {
        self.screen = screen
    }

    public func perform(
        container: Container,
        navigator: ScreenNavigator,
        completion: @escaping Completion
    ) {
        navigator.logInfo("Setting up side menu gesture in \(type(of: container)) with \(screen)")

        let newTab = screen.build(navigator: navigator)
        SideMenuManager.default.addPanGestureToPresent(toView: container.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: container.view)

        completion(.success(newTab))
    }
}

extension ScreenThenable where Current: UINavigationController {

    public func setupSideMenuGesture<New: Screen, Route: ScreenThenable>(
        with screen: New,
        route: Route
    ) -> Self where New.Container: UIViewController, Route.Root == New.Container {
        fold(
            action: ScreenSetupSideMenuGestureAction<New, Current>(screen: screen),
            nested: route
        )
    }

    public func setupSideMenuGesture<New: Screen>(
        with screen: New,
        route: (_ route: ScreenRootRoute<New.Container>) -> ScreenRouteConvertible = { $0 }
    ) -> Self where New.Container: UIViewController {
        setupSideMenuGesture(with: screen, route: route(.initial).route())
    }
}
