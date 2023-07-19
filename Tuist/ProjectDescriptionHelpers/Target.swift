import ProjectDescription

enum App {
    static let bundleId = "com.nugmanoff.cia"
    static let displayName = "Create iOS App"
    static let organizationName = "nugmanoff"
    static let deploymentTarget = "13.0"
    
    static let developmentTeamId = "8526SDA4V4"
    static let mainTargetName = "App"
}

extension Project {
    public static func main() -> Project {
        Project(
            name: App.mainTargetName,
            organizationName: App.organizationName,
            settings: Settings.settings(configurations: TargetConfiguration.allCases.map { $0.configuration() }),
            targets: [
                app(name: App.mainTargetName, dependencies: [
                    .target(name: "UI"),
                    .target(name: "Infra"),
                    .target(name: "Resources"),
                    .target(name: "Convenience"),
                    .external(name: "Inject"),
                    .external(name: "Nivelir"),
                    .external(name: "SideMenu"),
                    .external(name: "Factory"),
                    .external(name: "Pulse"),
                    .external(name: "PulseUI")
                ]),
                module(name: "UI", dependencies: [
                    .target(name: "Resources"),
                    .target(name: "Convenience")
                ]),
                module(name: "Infra", noResources: false, dependencies: [
                    .external(name: "Alamofire"),
                    .external(name: "Pulse")
                ]),
                module(name: "Resources", noResources: false),
                module(name: "Convenience")
            ],
            schemes: TargetScheme.allCases.map { $0.getScheme(for: App.mainTargetName) },
            fileHeaderTemplate: .string("")
        )
    }
    
    private static func app(name: String, dependencies: [TargetDependency] = []) -> Target {
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
            "CFBundleIdentifier": "$(APP_BUNDLE_IDENTIFIER)",
            "CFBundleName": "$(APP_BUNDLE_NAME)",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen",
            "NSBonjourServices": ["_pulse._tcp"]
        ]
        
        
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: "$(APP_BUNDLE_IDENTIFIER)",
            deploymentTarget: .iOS(targetVersion: App.deploymentTarget, devices: .iphone),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/App/Sources/**"],
            resources: ["Targets/App/Resources/**"],
            dependencies: dependencies
        )
    }
    
    public static func module(name: String, noResources: Bool = true, dependencies: [TargetDependency] = []) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "com.\(name).module",
            deploymentTarget: .iOS(targetVersion: App.deploymentTarget, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: noResources ? [] : ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )
    }
}
