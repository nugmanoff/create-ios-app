import SwiftUI

public struct QLoader: UIViewRepresentable {
    public typealias UIViewType = UIActivityIndicatorView

    public let style: UIActivityIndicatorView.Style
    public let color: UIColor
    
    public init(style: UIActivityIndicatorView.Style, color: UIColor) {
        self.style = style
        self.color = color
    }

    public func makeUIView(context: UIViewRepresentableContext<QLoader>) -> QLoader.UIViewType {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: QLoader.UIViewType, context: UIViewRepresentableContext<QLoader>) {
        uiView.startAnimating()
        uiView.color = color
    }
}
