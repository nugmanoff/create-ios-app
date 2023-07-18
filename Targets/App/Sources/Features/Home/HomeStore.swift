import Foundation
import Convenience

enum HomeEvent {
    case profileNameLoaded(String)
}

enum HomeAction {
    case viewDidAppear
}

final class HomeStore: Store<HomeEvent, HomeAction> {
    private var getProfileUseCase = GetProfileUseCase()
    
    override func handleActions(action: HomeAction) {
        switch action {
        case .viewDidAppear:
            print("viewDidAppear Action Received")
            Task {
                let profile = await getProfileUseCase.execute()
                sendEvent(.profileNameLoaded(profile.name))
            }
        }
    }
}
