//import SwiftUI
//import Combine
//
//public protocol BaseViewController: UIViewController {
//    var onRemoveFromNavigationStack: (() -> Void)? { get set }
//    var onDidDismiss: (() -> Void)? { get set }
//}
//
//open class ViewController: UIViewController, BaseViewController {
//    public var onRemoveFromNavigationStack: (() -> Void)?
//    public var onDidDismiss: (() -> Void)?
//
//    private var languageChangeObservation: AnyCancellable?
//    private let network = NetworkReachability.shared
//    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//
//        removeBackButtonTitle()
//        localize()
//        observeLanguageChange()
//    }
//
//    open override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        removeBackButtonTitle()
//    }
//
//    override public func didMove(toParent parent: UIViewController?) {
//        super.didMove(toParent: parent)
//        if parent == nil {
//            onRemoveFromNavigationStack?()
//        }
//    }
//
//    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        super.dismiss(animated: flag) { [weak self] in
//            completion?()
//            self?.onDidDismiss?()
//        }
//    }
//
//    func localize() {
//        // Implement this method to change language on fly
//    }
//
//    private func removeBackButtonTitle() {
//        navigationItem.backButtonDisplayMode = .minimal
//    }
//
//    @objc func navigationShouldPopOnBackButton() -> Bool {
//        return true
//    }
//}
//
//private extension ViewController {
//    private func observeLanguageChange() {
//        languageChangeObservation = LanguageManager.shared.$current
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.localize()
//            }
//    }
//}
