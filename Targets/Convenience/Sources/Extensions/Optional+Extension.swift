import Foundation

public extension Optional {
    var isExist: Bool {
        if case .some = self {
            return true
        }
        return false
    }
}
