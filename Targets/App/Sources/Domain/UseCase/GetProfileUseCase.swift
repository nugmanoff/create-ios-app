import Foundation
import Convenience

protocol GetProfileUseCaseProtocol {
    func execute() async -> UserProfile
}

final class GetProfileUseCase: GetProfileUseCaseProtocol {
    func execute() async -> UserProfile {
        let profile = await userRepository.fetchUserProfile()
        return profile
    }
}

final class GetMockProfileUseCase: GetProfileUseCaseProtocol {
    func execute() async -> UserProfile {
        UserProfile(name: "Mocked Name")
    }
}

