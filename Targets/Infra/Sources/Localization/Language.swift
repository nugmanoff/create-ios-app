import Foundation
import Infra

public enum Language: String, Identifiable, UserDefaultsSerializable, CaseIterable {
    case english
    case russian

    public var id: String { rawValue }

    var identifier: String {
        switch self {
        case .english:
            return "en"
        case .russian:
            return "ru"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    static var `default`: Language {
        .english
    }
}

extension Language: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
