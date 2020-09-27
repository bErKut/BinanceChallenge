import UIKit

class HistoryCell: UICollectionViewCell {
    private enum Const {
        static let spacing: CGFloat = 4
        static let timeRelativeWidth: CGFloat = 0.3
        static let quantityRelativeWidth: CGFloat = 0.25
    }
    
    var time: String? {
        get { timeLabel.text }
        set { timeLabel.text = newValue }
    }
    
    var price: String? {
        get { priceLabel.text }
        set { priceLabel.text = newValue }
    }
    
    var quantity: String? {
        get { quantityLabel.text }
        set { quantityLabel.text = newValue}
    }
    
    private let timeLabel = UILabel()
    private let priceLabel = UILabel()
    private let quantityLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for label in [timeLabel, priceLabel, quantityLabel] {
            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
         timeLabel.topAnchor.constraint(equalTo: topAnchor),
         timeLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                          multiplier: Const.timeRelativeWidth),
         timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
         
         priceLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
         priceLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
         priceLabel.widthAnchor.constraint(equalTo: timeLabel.widthAnchor),
         priceLabel.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor),
         
         quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
         quantityLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
         quantityLabel.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor),
         quantityLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                              multiplier: Const.quantityRelativeWidth)
            
        ].activate()

    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
