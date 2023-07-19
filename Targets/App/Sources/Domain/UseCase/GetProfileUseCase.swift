import Factory

protocol GetProfileUseCaseProtocol {
    func execute() async -> UserProfile
}

final class GetProfileUseCase: GetProfileUseCaseProtocol {
    @Injected(\.userRepository) var userRepository
    
    func execute() async -> UserProfile {
        let profile = await userRepository.fetchUserProfile()
        return profile
    }
}

final class GetProfileUseCaseMock: GetProfileUseCaseProtocol {
    func execute() async -> UserProfile {
        UserProfile(name: "Mocked Name")
    }
}

