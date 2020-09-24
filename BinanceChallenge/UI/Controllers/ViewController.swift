import UIKit

class ViewController: UIViewController {
    
    private let store: Store
    private let segmentedControl = UISegmentedControl(items: [Strings.orderBook,
                                                              Strings.marketHistory])
    private let contentView = UIView()
    private let contentViewController = UIPageViewController(transitionStyle: .scroll,
                                                             navigationOrientation: .horizontal,
                                                             options: nil)
    private let orderBookController: OrderBookViewController
    private let marketHistoryController: MarketHistoryViewController
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(store: Store) {
        self.store = store
        orderBookController = OrderBookViewController(store: store)
        marketHistoryController = MarketHistoryViewController(store: store)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self,
                                   action: #selector(onSegment(_:)),
                                   for: .valueChanged)
        view.addSubview(contentView)
        
        configureUI()
        
        let _ = store.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentViewController.view.frame = self.view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @objc private func onSegment(_ segmentedControl: UISegmentedControl) {
        let selectedTitle = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
        let controller: UIViewController
        let direction: UIPageViewController.NavigationDirection
        
        switch selectedTitle {
        case Strings.orderBook:
            controller = orderBookController
            direction = .reverse
        case Strings.marketHistory:
            controller = marketHistoryController
            direction = .forward
        default:
            return
        }
        
        contentViewController.setViewControllers([controller],
                                                 direction: direction,
                                                 animated: true,
                                                 completion: nil)
    }
}

// MARK: UI configuration
private extension ViewController {
    private enum Strings {
        static let orderBook = "Order Book"
        static let marketHistory = "Market History"
    }
    
    private enum Const {
        static let segmentedControlWidth: CGFloat = 44
    }

    func configureUI() {
        configureSegmentedControl()
        configureContentView()
        positionElements()
        installPageViewController()
    }
    
    func configureSegmentedControl() {
        segmentedControl.backgroundColor = .lightGray
        // TODO: tune appearence
    }
    
    func configureContentView() {
        contentView.backgroundColor = .cyan
        // TODO: tune appearence
    }
    
    func positionElements() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor),
         segmentedControl.heightAnchor.constraint(equalToConstant: Const.segmentedControlWidth),
                           
         contentView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
         contentView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
         contentView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor),
         contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].activate()
    }
    
    func installPageViewController() {
        contentView.addSubview(contentViewController.view)
        addChild(contentViewController)
        contentViewController.didMove(toParent: self)
        contentViewController.dataSource = self
        contentViewController.view.backgroundColor = .yellow
        
        orderBookController.view.backgroundColor = .red
        marketHistoryController.view.backgroundColor = .green
        
        contentViewController.setViewControllers([orderBookController],
                                                 direction: .forward,
                                                 animated: true,
                                                 completion: nil)
    }
}

// MARK: UIPageViewControllerDataSource
extension ViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard viewController == marketHistoryController else { return nil }
        return orderBookController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard viewController == orderBookController else { return nil }
        return marketHistoryController
    }
}
