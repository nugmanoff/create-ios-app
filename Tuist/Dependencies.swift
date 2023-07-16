import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/krzysztofzablocki/Inject.git", requirement: .upToNextMajor(from: .init(stringLiteral: "1.0.5")))
    ],
    platforms: [.iOS]
)
