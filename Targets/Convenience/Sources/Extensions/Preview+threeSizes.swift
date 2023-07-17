import SwiftUI

public extension View {
    func previewThreeSizes() -> some View {
        Group {
            self
                .previewDevice("iPhone 12 mini")
                .previewDisplayName("Mini")
            self
                .previewDevice("iPhone 12")
                .previewDisplayName("Normal")
            self
                .previewDevice("iPhone 12 Pro Max")
                .previewDisplayName("Max")
        }
    }
}
