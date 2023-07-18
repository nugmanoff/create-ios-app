import Foundation
import Convenience

protocol UpdateProfileNameUseCaseProtocol {
    func execute(_ profileName: String) async
}

final class UpdateProfileNameUseCase: UpdateProfileNameUseCaseProtocol {
    func execute(_ profileName: String) async {
        await userRepository.updateUserProfile(UserProfile(name: profileName))
    }
}
