import Foundation
import Nivelir

struct AppScreens {
    func enterUsernameScreen() -> AnyModalScreen {
        AuthEnterUsernameScreen().eraseToAnyScreen()
    }
    
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
