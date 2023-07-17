import Combine
import Foundation

/// A property wrapper that uses `UserDefaults` as a backing store,
/// whose `wrappedValue` is non-optional and registers a **non-optional default value**.
@propertyWrapper
public struct Stored<T: UserDefaultsSerializable> {
    private let _userDefaults: UserDefaults
    private let _publisher: CurrentValueSubject<T, Never>

    /// The key for the value in `UserDefaults`.
    public let key: String

    /// The value retrieved from `UserDefaults`.
    public var wrappedValue: T {
        get {
            _userDefaults.fetch(key)
        }
        set {
            _userDefaults.save(newValue, for: key)
            _publisher.send(newValue)
        }
    }

    /// A publisher that delivers updates to subscribers.
    public var projectedValue: AnyPublisher<T, Never> {
        _publisher.eraseToAnyPublisher()
    }

    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - wrappedValue: The default value to register for the specified key.
    ///   - keyName: The key for the value in `UserDefaults`.
    ///   - userDefaults: The `UserDefaults` backing store. The default value is `.standard`.
    public init(wrappedValue: T, key keyName: String, userDefaults: UserDefaults = .standard) {
        key = keyName
        _userDefaults = userDefaults
        userDefaults.registerDefault(value: wrappedValue, key: keyName)

        // Publisher must be initialized after `registerDefault`,
        // because `fetch` assumes that `registerDefault` has been called before
        // and uses force unwrap
        _publisher = CurrentValueSubject<T, Never>(userDefaults.fetch(keyName))
    }
}
