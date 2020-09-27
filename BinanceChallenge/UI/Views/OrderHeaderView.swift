import UIKit

class OrderHeaderView: UIView {
    private enum Consts {
        static let precitionButtonMinWidth: CGFloat = 44
    }
    
    private enum Strings {
        static let bid = "Bid"
        static let ask = "Ask"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .dark
        let bidLabel = UILabel(text: Strings.bid,
                               textColor: .pale)
        let askLabel = UILabel(text: Strings.ask,
                               textColor: .pale)
        let precisionButton = UIButton(type: .custom)
        precisionButton.backgroundColor = .yellow // TODO: implement
        
        for view in [bidLabel, askLabel, precisionButton] {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [bidLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
         bidLabel.topAnchor.constraint(equalTo: topAnchor),
         bidLabel.trailingAnchor.constraint(equalTo: centerXAnchor),
         bidLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        
         askLabel.leadingAnchor.constraint(equalTo: centerXAnchor),
         askLabel.topAnchor.constraint(equalTo: topAnchor),
         askLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
         askLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                           
         precisionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
         precisionButton.topAnchor.constraint(equalTo: bidLabel.topAnchor),
         precisionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Consts.precitionButtonMinWidth),
         precisionButton.bottomAnchor.constraint(equalTo: bidLabel.bottomAnchor)
        ].activate()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
