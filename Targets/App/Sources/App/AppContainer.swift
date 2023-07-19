import Foundation
import Factory
import Infra
import Nivelir

typealias AppContainer = Container
typealias Dependency = Factory
typealias ParametrizedDependency = ParameterFactory

extension AppContainer: AutoRegistering {
    public func autoRegister() {
        /// Makes all of the registrations in scope `.singleton` by default
        manager.defaultScope = .singleton
    }
}

extension AppContainer {
   
    var navigator: Dependency<ScreenNavigator> {
        self {
            /// Actual `ScreenNavigator` is instantiated and registered in `AppDelegate`
            /// This is made only to avoid `ScreenNavigator?` optional type
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
    
    var appCoordinator: Dependency<AppCoordinator> {
        self {
            AppCoordinator()
        }
        .shared
    }
    
    var authCoordinator: Dependency<AuthCoordinator> {
        self {
            AuthCoordinator()
        }
        .shared
    }
}
