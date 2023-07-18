import UIKit
import Nivelir

struct EditProfileScreen: Screen {
    func build(navigator: ScreenNavigator) -> UIViewController {
        EditProfileViewController(navigator: navigator)
    }
}
