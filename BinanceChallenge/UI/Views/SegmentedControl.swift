import UIKit

class SegmentedControl: UISegmentedControl {
    private enum Const {
        static let accentWidth: CGFloat = 28
        static let accentHeight: CGFloat = 2
    }
    
    private var selectedIndexKVOToken: NSKeyValueObservation?
    private let accentView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        
        backgroundColor = .dark
        var attributes: [NSAttributedString.Key: UIColor] = [ .foregroundColor: .golden ]
        setTitleTextAttributes(attributes, for: .selected)
        attributes = [ .foregroundColor: .paleLight]
        setTitleTextAttributes(attributes, for: .normal)
        let backGroundImage = UIImage(color: .clear, size: CGSize(width: 1, height: bounds.height))
        setBackgroundImage(backGroundImage, for: .normal, barMetrics: .default)
        
        accentView.backgroundColor = .golden
        addSubview(accentView)

        selectedIndexKVOToken = observe(\.selectedSegmentIndex, options: .new) { [weak self] _, change in
            self?.drawAccent(for: change.newValue)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawAccent(for: selectedSegmentIndex)
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
