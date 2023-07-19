import Infra
import Factory

struct AppCoordinator {
    @Injected(\UseCases.getUserFlowUseCase) var getUserFlowUseCase
    @Injected(\.navigator) var navigator
    @Injected(\.routes) var routes
    @Injected(\.authCoordinator) var authCoordinator
    
    func start() {
        let flow = getUserFlowUseCase.execute()
        switch flow {
        case .auth:
            authCoordinator.start()
        case .main:
            navigator.navigate(to: routes.showHomeRoute())
        }
    }
}
