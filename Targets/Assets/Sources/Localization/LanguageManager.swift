import Foundation

public final class LanguageManager: NSObject {
    public static let shared = LanguageManager()

    public var locale: Locale { current.locale }

    @Stored(key: "LanguageManager.current")
    public var current: Language = .english

    @Stored(key: "LanguageManager.isFirstLaunch")
    private var isFirstLaunch = true

    public func setupLanguage() {
        guard isFirstLaunch else { return }

        if let preferredLanguage = Locale.preferredLanguages.first {
            if preferredLanguage.contains(Language.english.identifier) {
                current = .english
            } else if preferredLanguage.contains(Language.russian.identifier) {
                current = .russian
            }
        }
        isFirstLaunch = false
    }

    override private init() {
        super.init()
    }
}
