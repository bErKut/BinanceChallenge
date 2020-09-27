import UIKit

class HistoryCell: UICollectionViewCell {
    private enum Const {
        static let spacing: CGFloat = 4
        static let sideOffset: CGFloat = 16
        static let timeRelativeWidth: CGFloat = 0.3
        static let quantityRelativeWidth: CGFloat = 0.25
        static let font = UIFont(name: "DIN Alternate",
                                 size: 16)
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
    
    private let timeLabel = UILabel(textColor: .white)
    private let priceLabel = UILabel(textColor: .emerald)
    private let quantityLabel = UILabel(textColor: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for label in [timeLabel, priceLabel, quantityLabel] {
            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = Const.font
        }
        
        [timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                            constant: Const.sideOffset),
         timeLabel.topAnchor.constraint(equalTo: topAnchor),
         timeLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                          multiplier: Const.timeRelativeWidth),
         timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
         
         priceLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
         priceLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
         priceLabel.widthAnchor.constraint(equalTo: timeLabel.widthAnchor),
         priceLabel.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor),
         
         quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -Const.sideOffset),
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
