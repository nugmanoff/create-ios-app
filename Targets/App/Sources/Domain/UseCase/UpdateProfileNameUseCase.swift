import Factory

protocol UpdateProfileNameUseCaseProtocol {
    func execute(_ profileName: String) async
}

final class UpdateProfileNameUseCase: UpdateProfileNameUseCaseProtocol {
    @Injected(\.userRepository) var userRepository
    
    func execute(_ profileName: String) async {
        await userRepository.updateUserProfile(UserProfile(name: profileName))
    }
}
