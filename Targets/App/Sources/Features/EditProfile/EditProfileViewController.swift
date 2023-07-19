import SwiftUI
import Convenience
import Nivelir
import Combine
import Factory
import UI

final class EditProfileViewController: UIViewController, UITextFieldDelegate {
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Profile name"
        field.borderStyle = .roundedRect
        return field
    }()
    private lazy var button = QButton(viewModel: buttonViewModel).bridge()
    
    private lazy var buttonViewModel = QButtonViewModel(
        title: "Save",
        onDidTap: onSaveDidTap
    )
    
    private var updateProfileUseCase = UpdateProfileNameUseCase()
    
    private var bag = Bag()
    
    @Injected(\.navigator) var navigator
    @Injected(\.screens) var screens
    
    private let store = EditProfileStore()
    
    init() {
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
    
    private func configureUI() {
        view.backgroundColor = .white
        
        add(button)
        button.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.view.heightAnchor.constraint(equalToConstant: 64),
            button.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            button.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            button.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 52),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Edit Profile"
        stack?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "x.circle"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onCloseDidTap))
    }
    
    private func configureObservers() {
        bindStore(store) { [weak self] event in
            guard let self else { return }
            switch event {
            case .isLoading(let isLoading):
                buttonViewModel.isLoading = isLoading
                break
            case .isSaveButtonEnabled(let isSaveButtonEnabled):
                buttonViewModel.isEnabled = isSaveButtonEnabled
                break
            case .showSuccess:
//                let homeScreen = screens.homeScreen()
                navigator.navigate { route in
                    route
                        .first(.stack)
                        .stackRoot
//                        .first(.container(key: homeScreen.key))
                        .refresh()
                }
                showSuccess()
                break
            }
        }
        .store(in: &bag)
        
        textField
            .textPublisher
            .receiveOnMainQueue()
            .sink(receiveValue: { [weak self] text in
                self?.store.sendAction(.textDidChange(text))
            })
            .store(in: &bag)
    }
    
    @objc private func onCloseDidTap() {
        navigator.navigate(from: presenting) { route in
            route.dismiss()
        }
    }
    
    private func onSaveDidTap() {
        store.sendAction(.saveButtonDidTap)
    }
    
    private func showSuccess() {
        let screen = EditProfileSuccessViewController()
        navigator.navigate(from: self) { route in
            route.stack.push(screen)
        }
    }
}

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }
}
