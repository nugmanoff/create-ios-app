import ProjectDescription

enum App {
    static let bundleId = "com.nugmanoff.cia"
    static let displayName = "Create iOS App"
    static let organizationName = "nugmanoff"
    static let deploymentTarget = "13.0"
    
    static let developmentTeamId = "8526SDA4V4"
    static let targetName = "App"
}

extension Project {
    public static func main() -> Project {
        Project(
            name: App.targetName,
            organizationName: App.organizationName,
            settings: Settings.settings(configurations: TargetConfiguration.allCases.map { $0.configuration() },
                                        defaultSettings: .recommended(excluding: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS"])),
            targets: [
                app(name: App.targetName, dependencies: [
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
                module(name: "Infra", withResources: true, dependencies: [
                    .external(name: "Alamofire"),
                    .external(name: "Pulse")
                ]),
                module(name: "Resources", withResources: true),
                module(name: "Convenience")
            ],
            schemes: TargetScheme.allCases.map { $0.getScheme(for: App.targetName) },
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
//            settings: .settings(defaultSettings: .recommended(excluding: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS"]))
        )
    }
    
    public static func module(name: String, withResources: Bool = false, dependencies: [TargetDependency] = []) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "com.\(name).module",
            deploymentTarget: .iOS(targetVersion: App.deploymentTarget, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: withResources ? ["Targets/\(name)/Resources/**"] : [],
            dependencies: dependencies
        )
    }
}
