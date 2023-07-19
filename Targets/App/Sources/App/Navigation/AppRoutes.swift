import Factory
import Nivelir

struct AppRoutes {
    @Injected(\.screens) var screens
    
    func showAuthRoute() -> ScreenWindowRoute {
        ScreenWindowRoute()
            .setRoot(
                to: screens
                    .enterUsernameScreen()
                    .withStackContainer()
            )
            .makeKeyAndVisible()
    }
    
    func showHomeRoute() -> ScreenWindowRoute {
        ScreenWindowRoute()
            .setRoot(
                to: screens
                    .homeScreen()
                    .withStackContainer()
            )
            .makeKeyAndVisible()
    }
    
    func showEditProfileRoute() -> ScreenWindowRoute {
        ScreenWindowRoute()
            .top(.container)
            .present(
                screens
                    .editProfileScreen()
                    .withStackContainer()
                    .withModalPresentationStyle(.fullScreen)
            )
            .resolve()
    }
    
    func showStocksListRoute() -> ScreenWindowRoute {
        ScreenWindowRoute()
            .top(.container)
            .present(
                screens
                    .stocksListScreen()
                    .withStackContainer()
                    .withModalPresentationStyle(.fullScreen)
            )
            .resolve()
    }
}
