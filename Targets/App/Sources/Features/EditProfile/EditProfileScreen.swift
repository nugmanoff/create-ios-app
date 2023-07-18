import UIKit
import Nivelir

struct EditProfileScreen: Screen {
    let screens: AppScreens

    func build(navigator: ScreenNavigator) -> UIViewController {
        EditProfileViewController(navigator: navigator, screens: screens)
    }
}
