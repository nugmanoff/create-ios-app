import Foundation
import Nivelir

struct AppScreens {
    func editProfileScreen() -> AnyModalScreen {
        EditProfileScreen().eraseToAnyScreen()
    }

    func homeScreen() -> AnyModalScreen {
        HomeScreen().eraseToAnyScreen()
    }
    
    func stocksListScreen() -> AnyModalScreen {
        StocksListScreen().eraseToAnyScreen()
    }
}
