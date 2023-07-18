import SwiftUI
import Convenience

struct EditProfileSuccessView: View {
    var body: some View {
        WithBackground(color: .green) {
            Text("Success!")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}
