import UIKit
import UI
import Nivelir
import Factory
import Convenience

final class AuthEnterPasswordViewController: UIViewController, Screen {
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        return field
    }()
    private lazy var button = QButton(viewModel: buttonViewModel).bridge()
    
    private lazy var buttonViewModel = QButtonViewModel(
        title: "Login",
        isEnabled: true,
        onDidTap: onNextDidTap
    )
    
    @Injected(\.routes) var routes
    @Injected(\.screens) var screens
    @Injected(\.navigator) var navigator
    @Injected(\.authCoordinator) var coordinator
    
    init() {
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
    
    private func onNextDidTap() {
        coordinator.onEnterPasswordNextDidTap(container: self)
    }
}
