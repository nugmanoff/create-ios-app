import ProjectDescription

public enum TargetScheme: CaseIterable {
    case staging
    case production
    
    public func getScheme(for target: String) -> Scheme {
        Scheme(
            name: schemeName(for: target),
            shared: true,
            buildAction: .init(targets: ["\(target)"]),
            runAction: .runAction(configuration: configurations.debug.name),
            archiveAction: .archiveAction(configuration: configurations.release.name),
            profileAction: .profileAction(configuration: configurations.release.name),
            analyzeAction: .analyzeAction(configuration: configurations.debug.name)
        )
    }
    
    private func schemeName(for target: String) -> String {
        switch self {
        case .production:
            return "\(target) Production"
        case .staging:
            return "\(target) Staging"
        }
    }

    private var configurations: (debug: TargetConfiguration, release: TargetConfiguration) {
        switch self {
        case .staging:
            return (.debugStaging, .releaseStaging)
        case .production:
            return (.debugProduction, .releaseProduction)
        }
    }
}
