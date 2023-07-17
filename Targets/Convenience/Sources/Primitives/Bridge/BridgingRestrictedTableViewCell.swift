import SwiftUI

open class BridgingRestrictedTableViewCell<Content: View>: UITableViewCell {
    private var hostingController = RestrictedUIHostingController<Content?>(rootView: nil)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clearBackgroundColors()
        selectionStyle = .none
    }

    required public init?(coder: NSCoder) {
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

public extension BridgingRestrictedTableViewCell {
    func set(rootView: Content, parentViewController: UIViewController) {
        hostingController = RestrictedUIHostingController(rootView: rootView)
        hostingController.view.invalidateIntrinsicContentSize()

        let shouldMoveParentViewController = hostingController.parent != parentViewController
        if shouldMoveParentViewController {
            parentViewController.addChild(hostingController)
        }

        if hostingController.view.superview == nil {
            contentView.addSubviewStickingToEdges(hostingController.view)
        }

        if shouldMoveParentViewController {
            hostingController.didMove(toParent: parentViewController)
        }

        clearBackgroundColors()
    }

    func clearBackgroundColors() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
    }
}
