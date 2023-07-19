import Factory

enum AppEnvironment: String {
    case staging
    case production
    
    static var current: AppEnvironment {
        #if STAGING
        return .staging
        #elseif PRODUCTION
        return .production
        #else
        return .staging
        #endif
    }
    
    var apiURL: String {
        switch self {
        case .staging:
            return "https://staging"
        case .production:
            return "https://production"
        }
    }
}

public final class Env: SharedContainer {
     public static let shared = Env()
     public let manager = ContainerManager()
}

extension Env {
    var current: Factory<AppEnvironment> {
        self { .current }
    }
    
    var apiUrl: Factory<String> {
        self { self.current().apiURL }
    }
}
