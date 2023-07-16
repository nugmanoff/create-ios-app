import ProjectDescription

public enum TargetConfiguration: CaseIterable {
    case debugStaging
    case debugProduction
    case releaseStaging
    case releaseProduction
}

extension TargetConfiguration {
    func configuration(displayName: String, targetName: String, bundleId: String) -> Configuration {
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name, settings: settings(displayName: displayName, targetName: targetName, bundleId: bundleId))
        case .releaseStaging, .releaseProduction:
            return .release(name: name, settings: settings(displayName: displayName, targetName: targetName, bundleId: bundleId))
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

    private func settings(displayName: String, targetName: String, bundleId: String) -> [String: SettingValue] {
        [
            "APP_BUNDLE_NAME": "\(targetName)",
            "APP_DISPLAY_NAME": appName(targetName: displayName),
            "APP_BUNDLE_IDENTIFIER": SettingValue(stringLiteral: bundleIdentifier(baseBundleId: bundleId)),
            "PRODUCT_BUNDLE_IDENTIFIER": SettingValue(stringLiteral: bundleIdentifier(baseBundleId: bundleId)),
//            "DEVELOPMENT_TEAM": "8526SDA4V4",
//            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": provisioningProfile(bundleId: bundleId),
            "CODE_SIGN_IDENTITY": codeSignIdentity(),
        ]
    }

    private func appName(targetName: String) -> SettingValue {
        switch self {
        case .debugStaging, .releaseStaging:
            return "\(targetName) Staging"
        case .debugProduction, .releaseProduction:
            return "\(targetName)"
        }
    }
    
    private func provisioningProfile(bundleId: String) -> SettingValue {
        switch self {
        case .debugStaging, .debugProduction:
            return "match Development \(bundleIdentifier(baseBundleId: bundleId))"
        case .releaseStaging:
            return "match AdHoc \(bundleIdentifier(baseBundleId: bundleId))"
        case .releaseProduction:
            return "match AppStore \(bundleIdentifier(baseBundleId: bundleId))"
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

    private func bundleIdentifier(baseBundleId: String) -> String {
        "\(baseBundleId)"
    }
}
