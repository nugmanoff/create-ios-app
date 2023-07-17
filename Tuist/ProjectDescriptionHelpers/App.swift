import ProjectDescription

extension Project {
    public static func app() -> Project {
        let name = "create-ios-app"
        let displayName = "Create iOS App"
        let bundleId = "com.nugmanoff.cia"
        let organizationName = "nugmanoff"
        
        let settings = Settings.settings(
            configurations: TargetConfiguration.allCases.map {
                $0.configuration(displayName: displayName, targetName: name, bundleId: bundleId)
            }
        )
        
        let _ = TargetScheme.allCases.map { $0.getScheme(for: name) }
        
        return Project(
            name: name,
            organizationName: organizationName,
//            settings: settings,
            targets: [
                main(name: name, displayName: displayName, bundleId: bundleId, settings: settings),
                module(name: "UI", dependencies: [.target(name: "Resources"), .target(name: "Convenience")]),
                module(name: "Infra", noResources: false, dependencies: [.external(name: "Alamofire"), .external(name: "Pulse")]),
                module(name: "Resources", noResources: false),
                module(name: "Convenience")
            ]
//            schemes: schemes
        )
    }
    
    public static func module(name: String, noResources: Bool = true, dependencies: [TargetDependency] = []) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "com.\(name).module",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone]),
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: noResources ? [] : ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )
    }
    
    private static func main(name: String, displayName: String, bundleId: String, settings: Settings) -> Target {
        let infoPlist: [String: InfoPlist.Value] = [
//            "CFBundleDisplayName": .string(displayName),
//            "CFBundleShortVersionString": .string(Versions.marketingVersion),
//            "CFBundleVersion": .string(Versions.buildVersion),
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen",
//            "UIAppFonts": [],
//            "NSBonjourServices": ["_pulse._tcp"]
        ]
        
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTarget: .iOS(targetVersion: "13.0", devices: .iphone),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/App/Sources/**"],
            resources: ["Targets/App/Resources/**"],
            dependencies: [
                .target(name: "UI"),
                .target(name: "Infra"),
                .target(name: "Resources"),
                .target(name: "Convenience"),
                .external(name: "Inject"),
                .external(name: "Nivelir"),
                .external(name: "Pulse"),
                .external(name: "PulseUI")
            ]
        )
    }
}
