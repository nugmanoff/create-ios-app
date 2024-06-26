import SwiftUI
import Convenience

struct MenuView: View {
    var onEditProfileDidTap: Callback = {}
    var onStocksListDidTap: Callback = {}
    
    var body: some View {
        ZStack {
            Color.blue
            VStack(alignment: .leading, spacing: 16) {
                Button(action: onStocksListDidTap) {
                    Text("Список акций")
                }
                Button(action: onEditProfileDidTap) {
                    Text("Редактировать профиль")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
