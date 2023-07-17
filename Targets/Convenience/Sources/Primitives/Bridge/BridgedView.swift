import UIKit
import SwiftUI

public typealias BridgedView = UIViewController

public extension View {
    func bridge() -> UIHostingController<Self> {
        RestrictedUIHostingController(rootView: self).apply { vc in
            vc.view.backgroundColor = .clear
        }
    }

    func bridgeAndApply(_ configurator: (UIView) -> Void) -> UIHostingController<Self> {
        bridge().apply { vc in
            configurator(vc.view)
        }
    }
}

