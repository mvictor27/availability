
import UIKit

class AvailabilityViewController: UIViewController {
    typealias ModelItemType = Hour
    typealias ViewCellType = OneLabelCenteredCollectionViewCell
    
    let hoursRowCellNo: CGFloat = 4
    let hoursLineCellNo: CGFloat = 4
    
    @IBOutlet weak var collectionContainerView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    internal var collectionLayout: UICollectionViewFlowLayout = {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        return $0
    }(UICollectionViewFlowLayout())
    
    fileprivate var collectionViewController: BaseCollectionViewController<Hour, OneLabelCenteredCollectionViewCell>!
    
   fileprivate var collectionItems: [Hour] = [] {
        willSet(newValue) {
            collectionViewController?.items = newValue
        }
    }
    
    fileprivate var weekDayCollectionLayout: UICollectionViewFlowLayout = {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        return $0
    }(UICollectionViewFlowLayout())
    
    var viewModel: AvailabilityViewModel!
    
    fileprivate var panGesture: UIPanGestureRecognizer!
    fileprivate var startIndex: Int!
    fileprivate var currentRow: Int = 0
    fileprivate var isSelectedInterval = false
    fileprivate var isCellSelected = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cellFrameWidth = collectionContainerView.bounds.width / hoursRowCellNo
        let cellFrameHeight = collectionContainerView.bounds.height / hoursLineCellNo
        collectionLayout.itemSize = CGSize(width: cellFrameWidth, height: cellFrameHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupUI() {
        view.backgroundColor = .gray
        
        viewModel = AvailabilityViewModel()
        
        collectionContainerView.setNeedsLayout()
        collectionContainerView.layoutIfNeeded()
        
        nextButton.isHidden = true
        
        collectionViewController = BaseCollectionViewController(with: configureCell())
        collectionViewController.collectionView?.backgroundColor = .clear
        collectionViewController.collectionView?.isScrollEnabled = false
        collectionViewController.collectionView?.allowsMultipleSelection = true
        collectionViewController.collectionView?.showsHorizontalScrollIndicator = false
        collectionViewController.collectionView?.showsVerticalScrollIndicator = false
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDrag(sender:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        panGesture.maximumNumberOfTouches = 1
        
        addChild(collectionViewController, on: collectionContainerView)
        
        collectionContainerView.addGestureRecognizer(self.panGesture)
        
        collectionItems = viewModel.hours()
    }
    
    func setupView() {
       
        collectionViewController.didDeselectItemAt = { _ in
            self.considerShowNextButton()
        }
        
        viewModel.showButtonCallback = { isHidden in
            self.nextButton.isHidden = isHidden
        }
    }
    
    func indexPathForLocation(_ location: CGPoint) -> IndexPath! {
        guard let indexPath = collectionViewController.collectionView?.indexPathForItem(at: location) else {
            return nil
        }
        
        return indexPath
    }
    
    //MARK: Actions Methods
    
    @IBAction func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        guard let selectedItems = collectionViewController.collectionView?.indexPathsForSelectedItems else {
            return
        }
        
        viewModel.extractInterval(selectedItems.sorted())
    }
    
    func considerShowNextButton() {
        guard let selectedItems = collectionViewController.collectionView?.indexPathsForSelectedItems else {
            return
        }
        
        viewModel.showButtonCallback(selectedItems.isEmpty)
    }

}

//MARK: Hours Collection View Configuration

extension AvailabilityViewController {
    internal func configureCell() -> DefaultCollectionCellConfiguration<Hour, OneLabelCenteredCollectionViewCell> {
        return DefaultCollectionCellConfiguration(layout: collectionLayout, items: collectionItems, configureCell: { (model, cell, indexPath) in
            cell.textLabel.text = model.rawValue
            
        }, actionCell: { selectedIndexPath in
            guard let cell = self.collectionViewController.collectionView?.cellForItem(at: selectedIndexPath) else {
                return
            }
            
            cell.isSelected = true
            self.considerShowNextButton()
        })
    }
}

//MARK: Gesture Recognizer

extension AvailabilityViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didDrag(sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            let location = sender.location(in: collectionViewController.collectionView)
            guard let index = indexPathForLocation(location), let cell = collectionViewController.collectionView?.cellForItem(at: index) else {
                return
            }
            
            startIndex = index.row
            isCellSelected = cell.isSelected
            
        } else if (sender.state == .changed) {
            let location = sender.location(in: collectionViewController.collectionView)
            guard let currentIndex = indexPathForLocation(location) else {
                return
            }
            
            switch isCellSelected {
            case true:
                deselectOrSelectCell(for: currentIndex.row, currentRow: &currentRow)
            case false:
                selectOrDeselectCell(for: currentIndex.row, currentRow: &currentRow)
            }
            
        } else if (sender.state == .ended) {
            considerShowNextButton()
        }
    }
}

//MARK: Selecting cells

extension AvailabilityViewController {
    fileprivate func deselectOrSelectCell(for row: Int, currentRow: inout Int) {
        if startIndex > row {
            if currentRow > row {
                let _ = (row...startIndex).map {
                    deselectItemIfNeeded(for: $0)
                }
                isSelectedInterval = false
            } else if currentRow < row {
                let _ = (currentRow...row).map {
                    selectItemIfNeeded(for: $0)
                }
                isSelectedInterval = true
            }
        } else if startIndex < row {
            if currentRow < row {
                let _ = (startIndex...row).map {
                    deselectItemIfNeeded(for: $0)
                }
                isSelectedInterval = false
            } else if currentRow > row {
                let _ = (startIndex...row).map {
                    selectItemIfNeeded(for: $0)
                }
                isSelectedInterval = true
            }
        }
        currentRow = row
    }
    
    fileprivate func selectOrDeselectCell(for row: Int, currentRow: inout Int) {
        if startIndex > row {
            if currentRow > row {
                let _ = (row...startIndex).map {
                    selectItemIfNeeded(for: $0)
                }
                isSelectedInterval = true
            } else if currentRow < row {
                let _ = (currentRow...row).map {
                    deselectItemIfNeeded(for: $0)
                }
                isSelectedInterval = false
            }
        } else if startIndex < row {
            if currentRow < row {
                let _ = (startIndex...row).map {
                    selectItemIfNeeded(for: $0)
                }
                isSelectedInterval = true
            } else if currentRow > row {
                let _ = (row...currentRow).map {
                    deselectItemIfNeeded(for: $0)
                }
                isSelectedInterval = false
            }
        }
        
        currentRow = row
    }
    
    fileprivate func deselectItemIfNeeded(for row: Int) {
        let index = IndexPath(row: row, section: 0)
        collectionViewController.collectionView?.deselectItem(at: index, animated: true)
    }
    
    fileprivate func selectItemIfNeeded(for row: Int) {
        let index = IndexPath(row: row, section: 0)
        
        collectionViewController.collectionView?.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension UIViewController {
    /**
     Presenting an Child View Controller
     */
    func addChild(_ viewController: UIViewController, on view: UIView?) {
        var holderView = self.view
        if let onView = view {
            holderView = onView
        }
        addChildViewController(viewController)
        holderView?.addSubview(viewController.view)
        constrainViewEqual(holderView!, view: viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    func constrainViewEqual(_ holderView: UIView, view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: holderView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: holderView.bottomAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: holderView.trailingAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: holderView.leadingAnchor).isActive = true
    }
}
