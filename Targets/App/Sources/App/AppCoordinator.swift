//import Foundation
//
//final class AppCoordinator: BaseCoordinator {
//    override func start() {
//        let coordinator = TabBarCoordinator(router: router)
//        addDependency(coordinator)
//        coordinator.start()
//    }
//    
//    override func start(with deeplink: AppDeeplink) {
//        if childCoordinators.isEmpty {
//            start()
//        }
//        handle(deeplink: deeplink)
//    }
//    
//    override func handle(deeplink: AppDeeplink) {
//        guard let tabBarCoordinator = childCoordinators.first as? TabBarCoordinator else { return }
//        tabBarCoordinator.handle(deeplink: deeplink)
//    }
//}
