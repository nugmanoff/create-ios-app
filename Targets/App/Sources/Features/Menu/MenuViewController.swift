import SwiftUI
import Convenience
import Nivelir
import Factory

final class MenuViewController: UIViewController {
    var onEditProfileDidTap: Callback = {}
    var onStocksListDidTap: Callback = {}
    
    private lazy var rootView: BridgedView = MenuView(
        onEditProfileDidTap: onEditProfileDidTap,
        onStocksListDidTap: onStocksListDidTap
    ).bridge()
    
    @Injected(\.navigator) var navigator
    
    init(onEditProfileDidTap: @escaping Callback, onStocksListDidTap: @escaping Callback) {
        self.onEditProfileDidTap = onEditProfileDidTap
        self.onStocksListDidTap = onStocksListDidTap
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configureUI() {
        addIgnoringSafeArea(rootView)
    }
}

