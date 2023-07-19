import SwiftUI
import Convenience
import SideMenu
import Nivelir
import Factory

struct Stock {
    let symbol: String
    let value: String
}

final class StocksListViewModel {
    var stocks: [Stock] = [
        .init(symbol: "AAPL", value: "124.56$"),
        .init(symbol: "NFLX", value: "200.12$"),
        .init(symbol: "DISN", value: "72.11$"),
        .init(symbol: "GOOG", value: "56.84$"),
    ]
}

final class StocksListViewController: UIViewController {
    private lazy var tableView = UITableView()
    private lazy var viewModel = StocksListViewModel()
    
    @Injected(\.navigator) var navigator
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubviewStickingToEdges(tableView)
        tableView.apply {
            $0.dataSource = self
            $0.showsVerticalScrollIndicator = false
            $0.register(bridgingCellClass: StocksListItemCell.self)
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Stocks"
        stack?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "x.circle"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onCloseDidTap))
    }
    
    @objc private func onCloseDidTap() {
        navigator.navigate(from: presenting) { route in
            route.dismiss()
        }
    }
}

extension StocksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stock = viewModel.stocks[indexPath.row]
        let cell: StocksListItemCell = tableView.dequeueReusableBridgingCell(for: indexPath)
        let view = StocksListItemView(stock: stock)
        cell.set(rootView: view, parentViewController: self)
        return cell
    }
}
