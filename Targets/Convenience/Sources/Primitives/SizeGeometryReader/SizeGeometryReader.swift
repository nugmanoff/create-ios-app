import SwiftUI

public struct SizeGeometryReader: View {
    public var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizeUpdatingPreferenceKey.self, value: geometry.size)
        }
    }
}
