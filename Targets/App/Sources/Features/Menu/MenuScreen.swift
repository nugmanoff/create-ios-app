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
        
        let menu = SideMenuNavigationController(rootViewController: view).apply {
            $0.leftSide = true
            $0.presentationStyle = .menuSlideIn
        }
        
        return menu
    }
}
