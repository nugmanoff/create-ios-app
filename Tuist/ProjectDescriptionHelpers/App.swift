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
        
        let schemes = TargetScheme.allCases.map { $0.getScheme(for: name) }
        
        return Project(
            name: name,
            organizationName: organizationName,
//            settings: settings,
            targets: [
                makeMainTarget(name: name, displayName: displayName, bundleId: bundleId, settings: settings),
                Target(name: "resources",
                       platform: .iOS,
                       product: .framework,
                       bundleId: "com.nugmanoff.resources.module",
                       deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone]),
                       infoPlist: .default,
                       sources: "Targets/Assets/Sources/**",
                       resources: "Targets/Assets/Resources/**"
                       )
            ]
//            schemes: schemes
        )
    }
    
    public static func module() -> Project {
        let bundleId = "com.sample.module"
        let fonts: [String: InfoPlist.Value] = [
            "UIAppFonts":
                [
                    "Inter-Medium",
                    "Inter-Regular",
                ]
            
        ]
        return Project(
            name: "resources",
//            settings: projectSettings,
            targets: [
                Target(name: "resources",
                       platform: .iOS,
                       product: .framework,
                       bundleId: bundleId,
                       deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone]),
                       infoPlist: .extendingDefault(with: fonts),
                       sources: ["Targets/Assets/Sources/**"],
                       resources: ["Targets/Assets/Resources/**"]
                       )
                ]
            )
    }
    
    private static func makeMainTarget(name: String, displayName: String, bundleId: String, settings: Settings) -> Target {
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
            dependencies: [.target(name: "resources"), .external(name: "Inject")]
//            .project(target: dependencyName, path: .relativeToManifest("../\(dependencyName)"))
//            settings: settings
//            settings: Settings.settings(
//                base: ["MARKETING_VERSION": "\(Versions.marketingVersion)",
////                       "CODE_SIGN_STYLE": "Manual",
////                       "DEVELOPMENT_TEAM": "2T3TCFDCA4",
//                       "OTHER_LDFLAGS": "-ObjC"],
//                configurations: [
//                    .debug(
//                        name: "Debug",
//                        settings: [:
////                            "PROVISIONING_PROFILE_SPECIFIER": "match Development com.chesslegends.ai",
////                            "CODE_SIGN_IDENTITY": "iPhone Developer"
//                        ]
//                    ),
//                    .release(
//                        name: "Release",
//                        settings: [:
////                            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.chesslegends.ai",
////                            "CODE_SIGN_IDENTITY": "iPhone Distribution"
//                        ]
//                    )
//                ]
//            )
        )
    }
}
