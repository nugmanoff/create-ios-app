import UIKit

public extension UITableView {
    /// Используется чтоб зарегистрировать UITableViewCells без xib
    func register(bridgingCellClass : AnyClass...) {
        bridgingCellClass.forEach { cell in
            register(bridgingCellClass: cell)
        }
    }
    
    /// Используется чтоб зарегистрировать UITableViewCells c xib
    func register(nibClasses : AnyClass...) {
        nibClasses.forEach { cell in
            register(nibClass: cell)
        }
    }
    
    // Используется чтоб зарегистрировать UITableViewCell без xib
    final func register(bridgingCellClass: AnyClass) {
        let reuseIdentifier = String(describing: bridgingCellClass)
        self.register(bridgingCellClass, forCellReuseIdentifier: reuseIdentifier)
    }

    /// Используется чтоб использовать UITableViewCell без xib
    func dequeueReusableBridgingCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let reuseIdentifier = String(describing: T.self)
        let bareCell = self.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = bareCell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(reuseIdentifier) matching type \(T.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }
    
    /// Используется чтоб зарегистрировать UITableViewCell c xib
    func register(nibClass: AnyClass) {
        let nib = UINib(nibName: String(describing: nibClass), bundle: Bundle(for: nibClass.self))
        register(nib, forCellReuseIdentifier: String(describing: nibClass))
    }
    
    /// Используется чтоб использовать UITableViewCell c xib
    func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: "\(Cell.self)", for: indexPath) as? Cell else {
            fatalError("register(cellClass:) has not been implemented")
        }
        return cell
    }
}
