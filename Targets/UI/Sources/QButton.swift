import SwiftUI
import Convenience

public final class QButtonViewModel: ObservableObject {
    public var title: String
    @Published public var isLoading: Bool
    @Published public var isEnabled: Bool
    public var onDidTap: Callback 
    
    public init(
        title: String = "",
        isLoading: Bool = false,
        isEnabled: Bool = false,
        onDidTap: @escaping Callback = {}
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.onDidTap = onDidTap
    }
}

public struct QButton: View {
    @ObservedObject public var viewModel: QButtonViewModel
    
    public init(viewModel: QButtonViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Button(action: viewModel.onDidTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(viewModel.isEnabled ? 1 : 0.5))
                if viewModel.isLoading {
                    QLoader(style: .medium, color: .white)
                } else {
                    Text(viewModel.title)
                }
            }
            .foregroundColor(.white)
        }
        .disabled(!viewModel.isEnabled)
    }
}
