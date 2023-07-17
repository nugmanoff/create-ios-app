import Foundation

@propertyWrapper
public struct StoredArray<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults

    public init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    public var wrappedValue: T {
        get {
            guard let data = userDefaults.object(forKey: key) as? Data else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            userDefaults.set(data, forKey: key)
        }
    }
}

/*
 
 App
 *
 Infrastructure * UI
 - Storage
 - Networking
 - Localization
 *
 Resources * Convenience
 
 */
