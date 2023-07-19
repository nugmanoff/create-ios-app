import Factory
import Infra

enum UserFlow {
    case auth
    case main
}

protocol GetUserFlowUseCaseProtocol {
    func execute() -> UserFlow
}

final class GetUserFlowUseCase: GetUserFlowUseCaseProtocol {
    @Stored(key: "UserFlow.isFirstLaunch")
    private var isFirstLaunch = true
    
    func execute() -> UserFlow {
        let flow: UserFlow
        if isFirstLaunch {
            flow = .auth
        } else {
            flow = .main
        }
        isFirstLaunch = false
        return flow
    }
}

final class GetUserFlowUseCaseMock: GetUserFlowUseCaseProtocol {
    func execute() -> UserFlow {
        .auth
    }
}

