import ProjectDescription

public enum TargetConfiguration: CaseIterable {
    case debugStaging
    case debugProduction
    case releaseStaging
    case releaseProduction
}

extension TargetConfiguration {
    func configuration() -> Configuration {
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name, settings: settings())
        case .releaseStaging, .releaseProduction:
            return .release(name: name, settings: settings())
        }
    }
    
    public func dependencyConfiguration() -> Configuration {
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name)
        case .releaseStaging, .releaseProduction:
            return .release(name: name)
        }
    }

    var name: ConfigurationName {
        switch self {
        case .debugStaging:
            return .configuration("Debug(Staging)")
        case .debugProduction:
            return .configuration("Debug(Production)")
        case .releaseStaging:
            return .configuration("Release(Staging)")
        case .releaseProduction:
            return .configuration("Release(Production)")
        }
    }

    private func settings() -> [String: SettingValue] {
        [
            "APP_BUNDLE_NAME": "\(App.mainTargetName)",
            "APP_DISPLAY_NAME": displayName(),
            "APP_BUNDLE_IDENTIFIER": "\(bundleIdentifier())",
            "PRODUCT_BUNDLE_IDENTIFIER": "\(bundleIdentifier())",
            "DEVELOPMENT_TEAM": "\(App.developmentTeamId)",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": provisioningProfile(),
            "CODE_SIGN_IDENTITY": codeSignIdentity(),
        ]
    }

    private func displayName() -> SettingValue {
        switch self {
        case .debugStaging, .releaseStaging:
            return "\(App.displayName) Staging"
        case .debugProduction, .releaseProduction:
            return "\(App.displayName)"
        }
    }
    
    private func provisioningProfile() -> SettingValue {
        switch self {
        case .debugStaging, .debugProduction:
            return "match Development \(bundleIdentifier())"
        case .releaseStaging:
            return "match AdHoc \(bundleIdentifier())"
        case .releaseProduction:
            return "match AppStore \(bundleIdentifier())"
        }
    }

    private func codeSignIdentity() -> SettingValue {
        switch self {
        case .debugStaging, .debugProduction:
            return "iPhone Developer"
        case .releaseStaging, .releaseProduction:
            return "iPhone Distribution"
        }
    }
    
    private func otherLinkerFlags() -> SettingValue {
        switch self {
        case .debugStaging, .debugProduction:
            return "-Xlinker -interposable"
        case .releaseStaging, .releaseProduction:
            return ""
        }
    }

    private func bundleIdentifier() -> String {
        switch self {
        case .debugStaging, .releaseStaging:
            return "\(App.bundleId).staging"
        case .debugProduction, .releaseProduction:
            return "\(App.bundleId)"
        }
    }
}
