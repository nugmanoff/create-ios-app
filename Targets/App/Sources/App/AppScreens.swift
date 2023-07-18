import Foundation
import Nivelir

struct AppScreens {
    let services: Services
    
    func editProfileScreen() -> AnyModalScreen {
        EditProfileScreen(screens: self).eraseToAnyScreen()
    }

    func homeScreen() -> AnyModalScreen {
        HomeScreen(screens: self).eraseToAnyScreen()
    }
    
    func stocksListScreen() -> AnyModalScreen {
        StocksListScreen(screens: self).eraseToAnyScreen()
    }
    
    // MARK: - Routes

    func showHomeRoute() -> ScreenWindowRoute {
        ScreenWindowRoute()
            .setRoot(
                to: homeScreen().withStackContainer()
            )
            .makeKeyAndVisible()
    }
    
    func showEditProfileRoute() -> ScreenWindowRoute {
        ScreenWindowRoute()
            .top(.container)
            .present(
                editProfileScreen()
                    .withStackContainer()
                    .withModalPresentationStyle(.fullScreen)
            )
            .resolve()
    }
    
    func showStocksListRoute() -> ScreenWindowRoute {
        ScreenWindowRoute()
            .top(.container)
            .present(
                stocksListScreen()
                    .withStackContainer()
                    .withModalPresentationStyle(.fullScreen)
            )
            .resolve()
    }
}
