import SwiftUI
import Convenience
import SideMenu
import Nivelir

final class StocksListViewController: UIViewController {
    private let navigator: ScreenNavigator
    private let screens: AppScreens
    
    init(navigator: ScreenNavigator, screens: AppScreens) {
        self.navigator = navigator
        self.screens = screens
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        view.backgroundColor = .white
    }
    
    private func configureUI() {
        navigationItem.title = "Stocks"
        stack?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "x.circle"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onCloseDidTap))
    }
    
    @objc private func onCloseDidTap() {
        navigator.navigate(from: presenting) { route in
            route.dismiss()
        }
    }
}

