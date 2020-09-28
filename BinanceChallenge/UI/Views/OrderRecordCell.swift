import UIKit

class OrderRecordCell: UICollectionViewCell {
    private enum Const {
        static let spacing: CGFloat = 4
        static let sideOffset: CGFloat = 16
        static let font = UIFont(name: "DIN Alternate",
                                 size: 16)
    }
    
    var bidQuantity: String? {
        get { bidQuantityLabel.text }
        set { bidQuantityLabel.text = newValue }
    }
    
    var bidPrice: String? {
        get { bidPriceLabel.text }
        set { bidPriceLabel.text = newValue}
    }
    
    var askQuantity: String? {
        get { askQuantityLabel.text }
        set { askQuantityLabel.text = newValue }
    }
    
    var askPrice: String? {
        get { askPriceLabel.text }
        set { askPriceLabel.text = newValue }
    }
    
    private let bidQuantityLabel = UILabel()
    private let bidPriceLabel = UILabel()
    private let askQuantityLabel = UILabel()
    private let askPriceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .dark
        configureLabels()
        
        let configureStackView: (UIStackView) -> Void = { stackView in
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.spacing = Const.spacing
            stackView.distribution = .fillEqually
        }
        
        let configureOrderStackView: (UIStackView) -> Void = { stackView in
            configureStackView(stackView)
            stackView.distribution = .fillProportionally
        }
        
        let bidStackView = UIStackView(arrangedSubviews: [bidQuantityLabel, bidPriceLabel])
        configureOrderStackView(bidStackView)
        
        let askStackView = UIStackView(arrangedSubviews: [askPriceLabel, askQuantityLabel])
        configureOrderStackView(askStackView)
        
        let rootStackView = UIStackView(arrangedSubviews: [bidStackView, askStackView])
        
        configureStackView(rootStackView)
        
        contentView.addSubview(rootStackView)
        
        [rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                constant: Const.sideOffset),
         rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -Const.sideOffset),
         rootStackView.topAnchor.constraint(equalTo: topAnchor),
         rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ].activate()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabels() {
        bidPriceLabel.textAlignment = .right
        askQuantityLabel.textAlignment = .right
        bidQuantityLabel.textColor = .white
        bidPriceLabel.textColor = .emerald
        askPriceLabel.textColor = .reddish
        askQuantityLabel.textColor = .white
        let labels = [bidQuantityLabel, bidPriceLabel, askPriceLabel, askQuantityLabel]
        for label in labels {
            label.font = Const.font
        }
    }
        
}
