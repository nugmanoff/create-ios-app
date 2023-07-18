import SwiftUI
import Convenience

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        WithBackground(color: .white) {
            VStack {
                Text("Welcome, \(viewModel.profileName)")
                    .font(.title)
                Spacer()
            }
            .padding(.top, 60)
        }
    }
}
