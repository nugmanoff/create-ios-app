import UIKit

public protocol InlineConfigurable {}

extension NSObject: InlineConfigurable {}

public extension InlineConfigurable {
    @discardableResult
    func apply(_ configurator: (Self) -> Void) -> Self {
        configurator(self)
        return self
    }
}
