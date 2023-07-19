import Foundation
import Factory
import Infra
import Nivelir

typealias AppContainer = Container
typealias Dependency = Factory
typealias ParametrizedDependency = ParameterFactory

extension AppContainer {
    var navigator: Dependency<ScreenNavigator> {
        self {
            ScreenNavigator(window: .init())
        }
    }
    
    var screens: Dependency<AppScreens> {
        self {
            AppScreens()
        }
    }
    
    var routes: Dependency<AppRoutes> {
        self {
            AppRoutes()
        }
    }
    
    var userRepository: Dependency<UserRepository> {
        self {
            UserRepository()
        }
    }
    
    var getProfileUseCase: Dependency<GetProfileUseCaseProtocol> {
        self {
            GetProfileUseCase()
//            GetProfileUseCaseMock()
        }
    }
    
    var getUserFlowUseCase: Dependency<GetUserFlowUseCaseProtocol> {
        self {
//            GetUserFlowUseCase()
            GetUserFlowUseCaseMock()
        }
    }
}

extension AppContainer: AutoRegistering {
    public func autoRegister() {
        manager.defaultScope = .singleton
    }
}
