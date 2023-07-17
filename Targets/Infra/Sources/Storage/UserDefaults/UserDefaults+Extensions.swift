import Foundation

public extension UserDefaults {
    func save<T: UserDefaultsSerializable>(_ value: T, for key: String) {
        if T.self == URL.self {
            // Hack for URL, which is special
            // See: http://dscoder.com/defaults.html
            // Error: Attempt to insert non-property list object, NSInvalidArgumentException
            set(value as? URL, forKey: key)
            return
        }
        set(value.storedValue, forKey: key)
    }

    func delete(for key: String) {
        removeObject(forKey: key)
    }

    func fetch<T: UserDefaultsSerializable>(_ key: String) -> T {
        fetchOptional(key)!
    }

    func fetchOptional<T: UserDefaultsSerializable>(_ key: String) -> T? {
        let fetched: Any?

        if T.self == URL.self {
            // Hack for URL, which is special
            // See: http://dscoder.com/defaults.html
            // Error: Could not cast value of type '_NSInlineData' to 'NSURL'
            fetched = url(forKey: key)
        } else {
            fetched = object(forKey: key)
        }

        if fetched == nil {
            return nil
        }

        return T(storedValue: fetched as! T.StoredValue)
    }

    func registerDefault<T: UserDefaultsSerializable>(value: T, key: String) {
        register(defaults: [key: value.storedValue])
    }
}
