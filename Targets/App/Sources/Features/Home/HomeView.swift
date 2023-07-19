import SwiftUI
import UI
import Convenience

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        WithBackground(color: .white) {
            VStack {
                if viewModel.isLoading {
                    QLoader(style: .large, color: .gray)
                } else {
                    Text("Welcome, \(viewModel.profileName)")
                        .font(.title)
                }
                Spacer()
            }
            .padding(.top, 60)
        }
    }
}
