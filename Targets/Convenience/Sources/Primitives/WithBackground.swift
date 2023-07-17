import SwiftUI

struct WithBackground<Content: View>: View {
    public var color: Color
    @ViewBuilder public var content: () -> Content
    
    public init(color: Color, content: @escaping () -> Content) {
        self.color = color
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            content()
        }
    }
}

public struct WithScrollableBackground<Content: View>: View {
    public var showsIndicators: Bool = false
    public var color: Color
    @ViewBuilder public var content: () -> Content
    
    public init(showsIndicators: Bool, color: Color, content: @escaping () -> Content) {
        self.showsIndicators = showsIndicators
        self.color = color
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: showsIndicators) {
                content()
            }
        }
    }
}

