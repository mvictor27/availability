
import UIKit

class OneLabelCenteredCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!

    fileprivate let gradientLayer: CAGradientLayer = {
        $0.startPoint = CGPoint(x: 0.0, y: 0.0)
        $0.endPoint = CGPoint(x: 1.0, y: 1.0)
        return $0
    }(CAGradientLayer())

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setTextColor(_ color: UIColor = .white) {
        minutesLabel.textColor = color
        textLabel.textColor = color
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}

extension OneLabelCenteredCollectionViewCell {
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                gradientLayer.colors = [UIColor.green.withAlphaComponent(7), UIColor.gray].map {
                    $0.cgColor
                }
                setTextColor()
            case false:
                gradientLayer.colors = [UIColor.clear].map {
                    $0.cgColor
                }
                setTextColor(.lightGray)
            }
        }
    }
}
