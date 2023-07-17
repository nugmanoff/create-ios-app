import Foundation

public extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    /// Returns a string formatted in a plural form. (RU)
    /// - Parameter formatStrings: A list of strings that contain 3 plular forms for the expression.
    /// 1. Regular (минут).
    /// 2. Numbers ending with 2, 3, 4 except for 12, 13, 14, (минуты).
    /// 3. Numbers ending with 1 except for 11 (минуту).
    /// E.g.: ["через %d минут", "через %d минуты", "через %d минуту"]
    /// - Parameter countable: A number that the expression should be formatted for.
    static func getPluralString(formatStrings: [String], countable: Int) -> String {
        guard formatStrings.count > 0 else { return "" }
        guard formatStrings.count == 4 else { return String(format: formatStrings[0], countable) }
        if countable == 1 {
            return String(format: formatStrings[0], countable)
        }
        let lastDigit = countable % 10
        let lastTwoDigits = countable % 100
        if lastDigit > 1 && lastDigit < 5 && (lastTwoDigits < 10 || lastTwoDigits > 20) {
            return String(format: formatStrings[1], countable)
        }
        if lastDigit == 1 && lastTwoDigits != 11 {
            return String(format: formatStrings[2], countable)
        }
        return String(format: formatStrings[0], countable)
    }
}
