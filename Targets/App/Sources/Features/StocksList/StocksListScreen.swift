import UIKit
import Nivelir
import SideMenu

struct StocksListScreen: Screen {
    let screens: AppScreens

    func build(navigator: ScreenNavigator) -> UIViewController {
        StocksListViewController(navigator: navigator, screens: screens)
    }
}
