import SwiftUI

public final class Haptics {
    private static let notificationfeedbackGenerator = UINotificationFeedbackGenerator()
    private static let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)

    public static func success() {
        notificationfeedbackGenerator.prepare()
        notificationfeedbackGenerator.notificationOccurred(.success)
    }

    public static func warning() {
        notificationfeedbackGenerator.prepare()
        notificationfeedbackGenerator.notificationOccurred(.warning)
    }

    public static func error() {
        notificationfeedbackGenerator.prepare()
        notificationfeedbackGenerator.notificationOccurred(.error)
    }

    public static func light() {
        lightImpactGenerator.prepare()
        lightImpactGenerator.impactOccurred()
    }

    public static func medium() {
        mediumImpactGenerator.prepare()
        mediumImpactGenerator.impactOccurred()
    }

    public static func heavy() {
        heavyImpactGenerator.prepare()
        heavyImpactGenerator.impactOccurred()
    }
}
