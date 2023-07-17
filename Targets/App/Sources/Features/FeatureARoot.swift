import SwiftUI
import Nivelir

struct FeatureACoordinator {
    
}

final class FeatureARootViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rootView = UIHostingController(
            rootView: FeatureARootView(
                onPushScreen1: {},
                onPushScreen2: {},
                onShowScreen3: {}
            )
        )
        addChild(rootView)
        rootView.view.frame = UIScreen.main.bounds
        view.addSubview(rootView.view)
    }
}

struct FeatureARootView: View {
    @ObserveInjection var inject
    
    var onPushScreen1: () -> Void = {}
    var onPushScreen2: () -> Void = {}
    var onShowScreen3: () -> Void = {}
    
    var body: some View {
        VStack {
            Button("Push Screen 1") {
                print("screen 1")
            }
            Button("Push Screen 2") {
                print("screen 2")
            }
            Button("Show Screen 3") {
                print("screen 3")
            }
        }
        .enableInjection()
    }
}
