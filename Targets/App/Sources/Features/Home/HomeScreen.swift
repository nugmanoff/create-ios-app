import UIKit
import Nivelir

struct HomeScreen: Screen {
    let screens: AppScreens

    func build(navigator: ScreenNavigator) -> UIViewController {
        let menuScreen = MenuScreen(screens: screens)
        
        let presentMenuRoute = ScreenWindowRoute()
            .top(.container)
            .present(menuScreen)
            .resolve()

        let view = HomeViewController(
            navigator: navigator,
            screens: screens,
            screenKey: key,
            onOpenMenu: {
                navigator.navigate(to: presentMenuRoute)
            }
        )
        
        return view
    }
}
