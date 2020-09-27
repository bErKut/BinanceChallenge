import UIKit

class MarketHistoryViewController: UIViewController {
    private static let cellId = "historyCell"
    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource()
    private let header = HistoryHeaderView()

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
        
        view.backgroundColor = .dark
        
        view.addSubview(header)
        
        collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: Self.cellId)
        collectionView.dataSource = dataSource
        view.addSubview(collectionView)
        installConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        store.marketHistoryCallback = { [weak self] result in
            var snapshot = NSDiffableDataSourceSnapshot<Section, HistoryRecord>()
            switch result {
            case let .success(records):
                snapshot.appendSections([.history])
                snapshot.appendItems(records)
            case .failure:
                snapshot.appendItems([])
            }
            self?.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.marketHistoryCallback = nil
        
        super.viewDidDisappear(animated)
    }
}

extension MarketHistoryViewController {
    private enum Const {
        static let headerHeight: CGFloat = 28
        static let cellHeight: CGFloat = 28
    }

    enum Section: Int {
        case history
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, HistoryRecord> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { cv, ip, historyRec -> UICollectionViewCell? in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: Self.cellId,
                                              for: ip) as! HistoryCell
            cell.time = historyRec.time
            cell.price = historyRec.price
            cell.quantity = historyRec.quantity

            return cell
        }
    }
    
    func makeListLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(Const.cellHeight)
            ),
            subitems: [item]
        )
        
        return NSCollectionLayoutSection(group: group)
    }
    
    func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout(section: makeListLayoutSection())
        return UICollectionView(frame: .zero,
                                collectionViewLayout: layout)
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
