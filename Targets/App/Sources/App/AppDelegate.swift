import UIKit
import resources
import Inject

class SomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: .init(x: 50, y: 50, width: 300, height: 300))
        imageView.image = ResourcesAsset.screenshotCorner.image
        let label = UILabel(frame: .init(x: 50, y: 50, width: 300, height: 100))
        label.text = "Inter"
//        label.text = L10n.Common.save()
        label.textColor = .black
        label.font = ResourcesFontFamily.Inter.regular.font(size: 26)
        
        let label2 = UILabel(frame: .init(x: 50, y: 150, width: 300, height: 100))
        label2.text = "Cal Sans"
        label2.textColor = .black
        label2.font = ResourcesFontFamily.CalSans.semiBold.font(size: 26)
//        label2.font = ResourcesFontFamily.Inter.medium.font(size: 26)
        
        let button = UIButton(frame: .init(x: 50, y: 450, width: 100, height: 100))
        button.setTitle("change", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(changeLanguageDidTap), for: .touchUpInside)
        view.backgroundColor = .white
//        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(label2)
        view.addSubview(button)
    }
    
    @objc
    private func changeLanguageDidTap() {
        print("didtap")
        LanguageManager.shared.current = LanguageManager.shared.current == .russian ? .english : .russian
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupNavigation()
        return true
    }
    
    private func setupNavigation() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = Inject.ViewControllerHost(SomeViewController())
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
