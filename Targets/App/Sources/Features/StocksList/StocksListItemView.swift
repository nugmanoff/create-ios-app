import SwiftUI
import Convenience

typealias StocksListItemCell = BridgingRestrictedTableViewCell<StocksListItemView>

struct StocksListItemView: View {
    var stock: Stock
    
    var body: some View {
        HStack {
            Text(stock.symbol)
                .foregroundColor(.black)
            Spacer()
            Text(stock.value)
                .foregroundColor(.black.opacity(0.5))
        }
        .font(.subheadline)
        .padding()
    }
}

