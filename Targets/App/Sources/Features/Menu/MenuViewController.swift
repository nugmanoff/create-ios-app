import SwiftUI
import Convenience

final class MenuViewController: UIViewController {
    var onEditProfileDidTap: Callback = {}
    var onStocksListDidTap: Callback = {}
    
    private lazy var rootView: BridgedView = MenuView(
        onEditProfileDidTap: onEditProfileDidTap,
        onStocksListDidTap: onStocksListDidTap
    ).bridge()
    
    init(onEditProfileDidTap: @escaping Callback, onStocksListDidTap: @escaping Callback) {
        super.init(nibName: nil, bundle: nil)
        self.onEditProfileDidTap = onEditProfileDidTap
        self.onStocksListDidTap = onStocksListDidTap
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
    }
}

