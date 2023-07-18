import Infra
import Factory

class AppCoordinator {
    @Stored(key: "AppCoordinator.isFirstLaunch")
    private var isFirstLaunch = true
    
    @Injected(\.navigator) var navigator
    @Injected(\.routes) var routes
    
    func start() {
        if isFirstLaunch {
            navigator.navigate(to: routes.showAuthRoute())
        } else {
            navigator.navigate(to: routes.showHomeRoute())
        }
        isFirstLaunch = false
    }
}
