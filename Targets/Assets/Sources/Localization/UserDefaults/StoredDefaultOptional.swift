import Combine
import Foundation

/// A property wrapper that uses `UserDefaults` as a backing store,
/// whose `wrappedValue` is optional and **does not provide default value**.
@propertyWrapper
public struct StoredDefaultOptional<T: UserDefaultsSerializable> {
    private let _userDefaults: UserDefaults
    private let _publisher: CurrentValueSubject<T?, Never>

    /// The key for the value in `UserDefaults`.
    public let key: String

    /// The value retreived from `UserDefaults`, if any exists.
    public var wrappedValue: T? {
        get {
            _userDefaults.fetchOptional(key)
        }
        set {
            if let newValue = newValue {
                _userDefaults.save(newValue, for: key)
                _publisher.send(newValue)
            } else {
                _userDefaults.delete(for: key)
                _publisher.send(nil)
            }
        }
    }

    /// A publisher that delivers updates to subscribers.
    public var projectedValue: AnyPublisher<T?, Never> {
        _publisher.eraseToAnyPublisher()
    }

    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - keyName: The key for the value in `UserDefaults`.
    ///   - userDefaults: The `UserDefaults` backing store. The default value is `.standard`.
    public init(key keyName: String, userDefaults: UserDefaults = .standard) {
        key = keyName
        _userDefaults = userDefaults
        _publisher = CurrentValueSubject<T?, Never>(userDefaults.fetchOptional(keyName))
    }
}
