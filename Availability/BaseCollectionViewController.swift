
import UIKit

class BaseCollectionViewController<ItemType, ViewCellType:UICollectionViewCell>: UICollectionViewController {
    typealias ConfigCellType = (_ item: ItemType, _ cell: ViewCellType, _ indexPath: IndexPath) -> Void
    typealias ActionCellType = (IndexPath) -> Void
    typealias CellAtIndexType = (ViewCellType?, IndexPath) -> Void
    typealias ShouldSelectType = (IndexPath) -> Bool
    
    fileprivate var configureCell: ConfigCellType
    fileprivate var actionCell: (ActionCellType)!
    
    var didDeselectItemAt: (ActionCellType)!
    
    var items: [ItemType] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    let identifier = String(describing: ViewCellType.self)
    
    convenience init(with config: DefaultCollectionCellConfiguration<ItemType, ViewCellType>) {
        
        
        self.init(withItems: config.items, layout: config.layout, configureCell: config.configureCell, actionCell: config.actionCell)
    }
    
    fileprivate init(withItems items: [ItemType], layout: UICollectionViewFlowLayout, configureCell: @escaping ConfigCellType, actionCell: ActionCellType!) {
        self.items = items
        self.configureCell = configureCell
        self.actionCell = actionCell
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
        setUpCollectionView()
    }
    
    fileprivate func setUpCollectionView() {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ViewCellType else {
            return .init()
        }
        
        // Configure the cell...
        let item = items[indexPath.row]
        
        configureCell(item, cell, indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        actionCell?(indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeselectItemAt?(indexPath)
    }
}
