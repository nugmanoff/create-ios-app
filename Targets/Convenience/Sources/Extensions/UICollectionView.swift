import UIKit

public extension UICollectionView {
    func register(_ cells: AnyClass...) {
        cells.forEach { cell in
            register(cell)
        }
    }
}

public extension UICollectionView {
    final func register(_ cellClass: AnyClass) {
        let reuseIdentifier = String(describing: cellClass)
        self.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let reuseIdentifier = String(describing: T.self)
        let bareCell = self.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = bareCell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(reuseIdentifier) matching type \(T.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }

    final func register(_ supplementaryViewType: AnyClass, ofKind elementKind: String) {
        let reuseIdentifier = String(describing: supplementaryViewType)
        self.register(
            supplementaryViewType,
            forSupplementaryViewOfKind: elementKind,
            withReuseIdentifier: reuseIdentifier
        )
    }

    final func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath) -> T {
        let reuseIdentifier = String(describing: T.self)
        let view = self.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(reuseIdentifier) "
                    + "matching type \(T.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the supplementary view beforehand"
            )
        }
        return typedView
    }
}
