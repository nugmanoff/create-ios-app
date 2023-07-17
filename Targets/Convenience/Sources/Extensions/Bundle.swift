import Foundation

public extension Bundle {
    var release: String {
        infoDictionary?["CFBundleShortVersionString"] as! String
    }
    var build: String {
        infoDictionary?["CFBundleVersion"] as! String
    }
    var version: String {
        "\(release).\(build)"
    }
}
