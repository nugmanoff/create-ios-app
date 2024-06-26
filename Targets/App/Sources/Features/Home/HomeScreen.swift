import UIKit
import Nivelir

struct HomeScreen: Screen {
    func build(navigator: ScreenNavigator) -> UIViewController {
        let menuScreen = MenuScreen()
        
        let presentMenuRoute = ScreenWindowRoute()
            .top(.container)
            .present(menuScreen)
            .resolve()

        let view = HomeViewController(
            screenKey: key,
            onOpenMenu: {
                navigator.navigate(to: presentMenuRoute)
            }
        )
        
        return view
    }
}
