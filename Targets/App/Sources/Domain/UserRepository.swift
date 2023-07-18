import Foundation
import Infra
import Convenience

struct UserProfile {
    let name: String
}

final class UserRepository {
    private var inMemoryUserProfile = UserProfile(name: "Default")
    
    func updateUserProfile(_ userProfile: UserProfile) async {
        await delay(seconds: 1.5)
        inMemoryUserProfile = userProfile
    }
    
    func fetchUserProfile() async -> UserProfile {
        await delay(seconds: 1.5)
        return inMemoryUserProfile
    }
}
