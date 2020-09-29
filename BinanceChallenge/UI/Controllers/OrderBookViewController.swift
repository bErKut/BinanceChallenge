import UIKit

class OrderBookViewController: UIViewController {
    private static let cellId = "recordCell"
    
    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource()
    private let header = OrderHeaderView()

    private let store: Store
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(store: Store) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(header)
        collectionView.dataSource = dataSource
        view.addSubview(collectionView)
        installConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        store.orderBookCallback = { [weak self] result in
            var snapshot = NSDiffableDataSourceSnapshot<Section, Record>()

            switch result {
            case let .success(records):
                snapshot.appendSections([.records])
                snapshot.appendItems(records)
            case .failure(_):
                // TODO: reflect in UI
                snapshot.appendItems([])
            }

            self?.dataSource.apply(snapshot,
                                   animatingDifferences: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.orderBookCallback = nil
        super.viewWillDisappear(animated)
    }
}

private extension OrderBookViewController {
    private enum Const {
        static let headerHeight: CGFloat = 28
    }
    
    enum Section: Int {
        case records
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Record> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { cv, ip, record -> UICollectionViewCell? in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: Self.cellId,
                                              for: ip) as! OrderRecordCell
            cell.configure(with: record)
            return cell
        }
    }
        
    func makeCollectionView() -> UICollectionView {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: UICollectionViewCompositionalLayout.list)
        cv.register(OrderRecordCell.self, forCellWithReuseIdentifier: Self.cellId)
        cv.backgroundColor = .dark
        return cv
    }
    
    func installConstraints() {
        header.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         header.topAnchor.constraint(equalTo: view.topAnchor),
         header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         header.heightAnchor.constraint(equalToConstant: Const.headerHeight),
         
         collectionView.leadingAnchor.constraint(equalTo: header.leadingAnchor),
         collectionView.topAnchor.constraint(equalTo: header.bottomAnchor),
         collectionView.trailingAnchor.constraint(equalTo: header.trailingAnchor),
         collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ].activate()
    }
}
