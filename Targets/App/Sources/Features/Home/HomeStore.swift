import Foundation
import Convenience
import Factory

enum HomeEvent {
    case profileNameLoaded(String)
    case isLoading(Bool)
}

enum HomeAction {
    case viewDidAppear
}

final class HomeStore: Store<HomeEvent, HomeAction> {
    @Injected(\UseCases.getProfileUseCase) private var getProfileUseCase
    
    override func handleAction(_ action: HomeAction) {
        switch action {
        case .viewDidAppear:
            print("viewDidAppear Action Received")
            
            Task {
                sendEvent(.isLoading(true))
                let profile = await getProfileUseCase.execute()
                sendEvent(.profileNameLoaded(profile.name))
                sendEvent(.isLoading(false))
            }
        }
    }
}
