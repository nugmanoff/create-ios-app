import SwiftUI
import Convenience
import Nivelir

final class EditProfileSuccessViewController: UIViewController, Screen {
    private lazy var rootView: BridgedView = EditProfileSuccessView().bridge()
    
    private let navigator: ScreenNavigator
    
    init(navigator: ScreenNavigator) {
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        addIgnoringSafeArea(rootView)
        stack?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "x.circle"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onCloseDidTap))
    }
    
    @objc private func onCloseDidTap() {
        navigator.navigate(from: presenting) { route in
            route.dismiss()
        }
    }
}

