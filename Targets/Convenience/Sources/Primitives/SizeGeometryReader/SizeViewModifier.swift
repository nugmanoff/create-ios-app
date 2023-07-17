import SwiftUI

public struct SizeViewModifier: ViewModifier {
    @Binding private var size: CGSize

    public init(size: Binding<CGSize>) {
        _size = size
    }

    public func body(content: Content) -> some View {
        content
            .background(SizeGeometryReader())
            .onPreferenceChange(SizeUpdatingPreferenceKey.self) {
                if size != $0 { size = $0 }
            }
    }
}
