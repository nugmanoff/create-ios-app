import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/krzysztofzablocki/Inject.git", requirement: .upToNextMajor(from: .init(stringLiteral: "1.0.5"))),
        .remote(url: "https://github.com/hhru/Nivelir.git", requirement: .upToNextMajor(from: .init(stringLiteral: "1.6.3"))),
        .remote(url: "https://github.com/kean/Pulse.git", requirement: .upToNextMajor(from: "2.1.3")),
        .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.6.4")),
        .remote(url: "https://github.com/jonkykong/SideMenu.git", requirement: .upToNextMajor(from: "6.0.0")),
        .remote(url: "https://github.com/hmlongco/Factory.git", requirement: .upToNextMajor(from: "2.2.0")),
    ],
    platforms: [.iOS]
)
