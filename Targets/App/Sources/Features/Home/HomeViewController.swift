import SwiftUI
import Convenience
import SideMenu
import Nivelir
import Factory

final class HomeViewController: UIViewController, ScreenRefreshableContainer, ScreenKeyedContainer {
    
    var onOpenMenu: Callback = {}
    
    private lazy var rootView: BridgedView = HomeView(viewModel: viewModel).bridge()
    
    private let viewModel = HomeViewModel()
    
    private let store = HomeStore()
    let screenKey: ScreenKey
    
    @Injected(\.screens) var screens
    @Injected(\.routes) var routes
    @Injected(\.navigator) var navigator
    @Injected(\Env.current) var currentEnv
    
    private var bag = Bag()

    init(screenKey: ScreenKey, onOpenMenu: @escaping Callback) {
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
        
        print("currentEnv: ", currentEnv.rawValue)
        print("apiURL: ", Env.shared.apiUrl())
        
        /* Можно на лету менять Environment Переменные, не меняя весь Environment */
        Env.shared.apiUrl.register { "some_random_url" }
        
        print("currentEnv: ", currentEnv.rawValue)
        print("apiUrl: ",  Env.shared.apiUrl())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.sendAction(.viewDidAppear)
    }
    
    func refresh(completion: @escaping () -> Void) {
        store.sendAction(.viewDidAppear)
        completion()
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
            case .isLoading(let isLoading):
                viewModel.isLoading = isLoading
            }
        }
        .store(in: &bag)
    }
    
    @objc private func onHamburgerMenuDidTap() {
        onOpenMenu()
    }
}

