import Factory

public final class UseCases: SharedContainer {
     public static let shared = UseCases()
     public let manager = ContainerManager()
}

extension UseCases: AutoRegistering {
    public func autoRegister() {
        /// Makes all of the registrations in scope `.unique` by default
        manager.defaultScope = .unique
    }
}

extension UseCases {
    var getProfileUseCase: Dependency<GetProfileUseCaseProtocol> {
        self {
            GetProfileUseCase()
//            GetProfileUseCaseMock()
        }
    }
    
    var getUserFlowUseCase: Dependency<GetUserFlowUseCaseProtocol> {
        self {
            GetUserFlowUseCase()
//            GetUserFlowUseCaseMock()
        }
    }
}
