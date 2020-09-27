import UIKit

class SegmentedControl: UISegmentedControl {
    private enum Const {
        static let accentWidth: CGFloat = 28
        static let accentHeight: CGFloat = 2
        static let separatorHeight: CGFloat = 1
        static let separatorAlpha: CGFloat = 0.2
        static let selectedFont = UIFont.systemFont(ofSize: 16,
                                                    weight: .bold)
        static let font = UIFont.systemFont(ofSize: 16,
                                            weight: .semibold)
    }
    
    private var selectedIndexKVOToken: NSKeyValueObservation?
    private let accentView = UIView()
    private let separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        
        backgroundColor = .dark
        var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.golden,
                                                        .font: Const.selectedFont]
        setTitleTextAttributes(attributes, for: .selected)
        attributes = [.foregroundColor: UIColor.paleLight,
                      .font: Const.font]
        setTitleTextAttributes(attributes, for: .normal)
        let backgroundImage = UIImage(color: .clear, size: CGSize(width: 1, height: bounds.height))
        setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        setDividerImage(backgroundImage,
                        forLeftSegmentState: .normal,
                        rightSegmentState: .normal,
                        barMetrics: .default)
        
        accentView.backgroundColor = .golden
        separatorView.backgroundColor = UIColor.darkText.withAlphaComponent(Const.separatorAlpha)
        addSubview(accentView)
        addSubview(separatorView)

        selectedIndexKVOToken = observe(\.selectedSegmentIndex, options: .new) { [weak self] _, change in
            self?.drawAccent(for: change.newValue)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawAccent(for: selectedSegmentIndex)
        separatorView.frame = CGRect(x: 0,
                                     y: bounds.height - Const.separatorHeight,
                                     width: bounds.width,
                                     height: Const.separatorHeight)
    }
        
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        selectedIndexKVOToken = nil
    }
    
    private func drawAccent(for segment: Int?, animated: Bool = false) {
        guard let index = segment else { return }
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        UIView.animateKeyframes(withDuration: CATransaction.animationDuration(),
                                delay: 0,
                                options: .calculationModePaced,
                                animations: {
            self.accentView.frame = CGRect(x: segmentWidth * CGFloat(index) + (segmentWidth - Const.accentWidth)/2,
                                           y: self.bounds.height - Const.accentHeight,
                                           width: Const.accentWidth,
                                           height: Const.accentHeight)
            })
    }
}
