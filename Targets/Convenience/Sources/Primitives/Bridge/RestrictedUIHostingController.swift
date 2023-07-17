import Foundation
import SwiftUI

final public class RestrictedUIHostingController<Content>: UIHostingController<Content> where Content: View {
    /// The hosting controller may in some cases want to make the navigation bar be not hidden.
    /// Restrict the access to the outside world, by setting the navigation controller to nil when internally accessed.
    public override var navigationController: UINavigationController? {
        nil
    }
}
