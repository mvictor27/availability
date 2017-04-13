import UIKit

struct DefaultCollectionCellConfiguration<ItemType, ViewCellType:UICollectionViewCell> {
    typealias ConfigureCellType = (ItemType, ViewCellType, IndexPath) -> Void
    typealias ActionCellType = (IndexPath) -> Void
    
    var layout: UICollectionViewFlowLayout
    var items: [ItemType]
    
    var configureCell: ConfigureCellType!
    var actionCell: ActionCellType!
}
