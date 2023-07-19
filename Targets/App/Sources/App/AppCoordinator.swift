import Infra
import Factory

class AppCoordinator {
    @Injected(\.getUserFlowUseCase) var getUserFlowUseCase
    @Injected(\.navigator) var navigator
    @Injected(\.routes) var routes
    
    func start() {
        let flow = getUserFlowUseCase.execute()
        switch flow {
        case .auth:
            navigator.navigate(to: routes.showAuthRoute())
        case .main:
            navigator.navigate(to: routes.showHomeRoute())
        }
    }
}
