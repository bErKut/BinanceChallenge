import UIKit

class ViewController: UIViewController {
    
    private let store: Store
    private let segmentedControl = SegmentedControl(items: [Strings.orderBook,
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
        view.backgroundColor = .dark
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
        store.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentViewController.view.frame = self.contentView.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @objc private func onSegment(_ sc: UISegmentedControl) {
        let controller = pages[sc.selectedSegmentIndex]
        let direction: UIPageViewController.NavigationDirection = sc.selectedSegmentIndex > 0 ? .forward : .reverse
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
        static let segmentedControlHeight: CGFloat = 44
    }

    func configureUI() {
        positionElements()
        installPageViewController()
    }
        
    func positionElements() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor),
         segmentedControl.heightAnchor.constraint(equalToConstant: Const.segmentedControlHeight),
                           
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
        contentViewController.delegate = self
                
        contentViewController.setViewControllers([orderBookController],
                                                 direction: .forward,
                                                 animated: true,
                                                 completion: nil)
    }
}

// MARK: UIPageViewControllerDataSource
extension ViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard viewController == marketHistoryController else { return nil }
        return orderBookController
    }
    
    func pageViewController(_ _: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard viewController == orderBookController else { return nil }
        return marketHistoryController
    }
}

// MARK: UIPageViewControllerDelegate
extension ViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating _: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted _: Bool) {
        if let controller = pageViewController.viewControllers?.filter({ !previousViewControllers.contains($0) }).first,
            let index = pages.firstIndex(of: controller) {
            segmentedControl.selectedSegmentIndex = index
        }
    }
    
    private var pages: [UIViewController] {
        [self.orderBookController, self.marketHistoryController]
    }
}
