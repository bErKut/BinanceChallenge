import UIKit

class OrderHeaderView: UIView {
    private enum Consts {
        static let precitionButtonMinWidth: CGFloat = 44
        static let spacing: CGFloat = 4
        static let sideOffset: CGFloat = 16
        static let precisionButtonColor = UIColor.white.withAlphaComponent(0.1)
        static let font = UIFont.systemFont(ofSize: 16,
                                            weight: .semibold)

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
        let precisionButton = makePrecisionButton()
        
        for view in [bidLabel, askLabel, precisionButton] {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [bidLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                           constant: Consts.sideOffset),
         bidLabel.topAnchor.constraint(equalTo: topAnchor),
         bidLabel.trailingAnchor.constraint(equalTo: centerXAnchor),
         bidLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        
         askLabel.leadingAnchor.constraint(equalTo: centerXAnchor,
                                           constant: Consts.spacing),
         askLabel.topAnchor.constraint(equalTo: topAnchor),
         askLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
         askLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                           
         precisionButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                   constant: -Consts.sideOffset),
         precisionButton.topAnchor.constraint(equalTo: bidLabel.topAnchor),
         precisionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Consts.precitionButtonMinWidth),
         precisionButton.bottomAnchor.constraint(equalTo: bidLabel.bottomAnchor)
        ].activate()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makePrecisionButton() -> UIButton {
        let precisionButton = UIButton(type: .custom)
        precisionButton.backgroundColor = Consts.precisionButtonColor
        let buttonTitleAttributes = [NSAttributedString.Key.font: Consts.font,
                                     NSAttributedString.Key.foregroundColor: UIColor.white]
        let buttonTitle = NSAttributedString(string: "0.01", attributes: buttonTitleAttributes)
        precisionButton.setAttributedTitle(buttonTitle, for: .normal)
        let arrowImage = UIImage(named:"arrow")?.withRenderingMode(.alwaysTemplate)
        precisionButton.setImage(arrowImage, for: .normal)
        precisionButton.imageView?.tintColor = .golden
        precisionButton.semanticContentAttribute = .forceRightToLeft
        precisionButton.contentMode = .center
        let insetAmount: CGFloat = 2
        precisionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        precisionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: 2*insetAmount)
        return precisionButton
    }
}
