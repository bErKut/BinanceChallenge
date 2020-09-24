import UIKit

class OrderRecordCell: UICollectionViewCell {
    private enum Const {
        static let spacing: CGFloat = 4
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
        
        [rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
         rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
         rootStackView.topAnchor.constraint(equalTo: topAnchor),
         rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ].activate()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
