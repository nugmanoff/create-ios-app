import Convenience
import Factory

enum EditProfileEvent {
    case isLoading(Bool)
    case isSaveButtonEnabled(Bool)
    case showSuccess
}

enum EditProfileAction {
    case textDidChange(String)
    case saveButtonDidTap
}


final class EditProfileStore: Store<EditProfileEvent, EditProfileAction> {
    @Injected(\UseCases.updateProfileNameUseCase) var updateProfileNameUseCase
    private var profileName: String = ""
    
    override func handleActions(action: EditProfileAction) {
        switch action {
        case .textDidChange(let text):
            profileName = text
            let isFieldTextValid = !text.isEmpty && text.count > 3
            sendEvent(.isSaveButtonEnabled(isFieldTextValid))
        case .saveButtonDidTap:
            Task {
                sendEvent(.isLoading(true))
                sendEvent(.isSaveButtonEnabled(false))
                await updateProfileNameUseCase.execute(profileName)
                sendEvent(.isLoading(false))
                sendEvent(.isSaveButtonEnabled(true))
                sendEvent(.showSuccess)
            }
        }
    }
}
