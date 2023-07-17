import SwiftUI

public class BridgingCollectionReusableView<Content: View>: UICollectionReusableView {
    private var hostingController = RestrictedUIHostingController<Content?>(rootView: nil)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        clearBackgroundColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
        hostingController = RestrictedUIHostingController<Content?>(rootView: nil)
    }
}

public extension BridgingCollectionReusableView {
    func set(rootView: Content, parentViewController: UIViewController) {
        hostingController = RestrictedUIHostingController(rootView: rootView)
        hostingController.view.invalidateIntrinsicContentSize()

        let shouldMoveParentViewController = hostingController.parent != parentViewController
        if shouldMoveParentViewController {
            parentViewController.addChild(hostingController)
        }

        if hostingController.view.superview == nil {
            addSubviewStickingToEdges(hostingController.view)
        }

        if shouldMoveParentViewController {
            hostingController.didMove(toParent: parentViewController)
        }

        clearBackgroundColors()
    }

    func clearBackgroundColors() {
        backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
    }
}
