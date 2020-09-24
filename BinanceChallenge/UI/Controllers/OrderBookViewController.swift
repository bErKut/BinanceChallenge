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
        header.backgroundColor = .green
        
        collectionView.register(OrderRecordCell.self, forCellWithReuseIdentifier: Self.cellId)
        collectionView.dataSource = dataSource
        view.addSubview(collectionView)
        installConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Record>()
        snapshot.appendSections([.records])
        // TODO: replace fakes
        let items = [Record(bid: Order(quantity: 0.15, price: 342.21),
                            ask: Order(quantity: 1.12, price: 795.21)),
                     Record(bid: Order(quantity: 0.34, price: 42.21),
                            ask: Order(quantity: 3.12, price: 1795.21))]
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
}

private extension OrderBookViewController {
    private enum Const {
        static let headerHeight: CGFloat = 44
        static let cellHeight: CGFloat = 40
    }
    
    enum Section: Int {
        case records
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Record> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { cv, ip, record -> UICollectionViewCell? in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: Self.cellId,
                                              for: ip) as! OrderRecordCell
            // TODO: configure cell
            cell.backgroundColor = ip.item % 2 == 0 ? .gray : .magenta
            
            cell.bidQuantity = String(record.bid.quantity)
            cell.bidPrice = String(record.bid.price)
            cell.askPrice = String(record.ask.price)
            cell.askQuantity = String(record.ask.quantity)

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
