import Foundation

public func delay(seconds: TimeInterval) async {
    do {
        let nanoseconds = 1_000_000_000 * seconds
        try await Task.sleep(nanoseconds: UInt64(nanoseconds))
    } catch {
        return
    }
}
