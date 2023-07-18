import SwiftUI
import Convenience
import SideMenu
import Nivelir

final class HomeViewController: UIViewController, ScreenRefreshableContainer, ScreenKeyedContainer {
    
    var onOpenMenu: Callback = {}
    
    private lazy var rootView: BridgedView = HomeView(viewModel: viewModel).bridge()
    
    private let viewModel = HomeViewModel()
    
    private let navigator: ScreenNavigator
    private let screens: AppScreens
    private let store = HomeStore()
    
    let screenKey: ScreenKey
    
    private var bag = Bag()

    init(navigator: ScreenNavigator, screens: AppScreens, screenKey: ScreenKey, onOpenMenu: @escaping Callback) {
        self.navigator = navigator
        self.screens = screens
        self.screenKey = screenKey
        self.onOpenMenu = onOpenMenu
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        configureObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("did appear")
        store.sendAction(.viewDidAppear)
    }
    
    func refresh(completion: @escaping () -> Void) {
//        store.sendAction(.viewDidAppear)
//        completion()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        addIgnoringSafeArea(rootView)
    }
    
    private func configureNavigationBar() {
        stack?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "line.3.horizontal.circle"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onHamburgerMenuDidTap))
        navigationItem.title = "Home"
    }
    
    private func configureObservers() {
        bindStore(store) { [weak self] event in
            guard let self else { return }
            switch event {
            case .profileNameLoaded(let profileName):
                viewModel.profileName = profileName
            }
        }
        .store(in: &bag)
    }
    
    @objc private func onHamburgerMenuDidTap() {
        onOpenMenu()
    }
}

