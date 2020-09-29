import Foundation

struct Record {
    let bid: Order?
    let ask: Order?
}

extension Record: Hashable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.ask == rhs.ask && lhs.bid == rhs.bid
    }
}

struct HistoryRecord {
    enum PriceChange {
        case raise
        case fall
    }
    let time: Int
    let price: Double
    let quantity: Double
    let priceChange: PriceChange
    private let uuid = UUID()
}

extension HistoryRecord: Hashable {
    static func ==(lhs: HistoryRecord, rhs: HistoryRecord) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

class Store {
    private enum Const {
        static let processingQueue = "com.berkut89.binancechallenge.store"
        static let historyRecordsMaxCount = 14
        static let depthRecordsCount = 14
        static let depthResponsesBufferSize = 10
    }
    
    private enum Symbol: String {
        case btcusdt = "btcusdt"
    }
    
    private var lastUpdateID: Int?
    
    // consider using another data structure in case if
    // performance will be not enough (i.e. doubly linked list)
    private var depthResponses: [DepthResponse] = []
    
    private var historyRecords: [HistoryRecord] = []
    private var histiryRecordsMaxCapacity = Const.historyRecordsMaxCount
        
    private var networker: Networker!
    private var processingQueue: OperationQueue {
        let queue = OperationQueue()
        
        // in case of change of the queue to concurrent – take care
        // of shared resources synchronisation
        queue.maxConcurrentOperationCount = 1
        queue.name = Const.processingQueue
        return queue
    }
    private let callbackQueue: OperationQueue
    var orderBookCallback: ((Result<[Record], Error>) -> Void)?
    var marketHistoryCallback: ((Result<[HistoryRecord], Error>) -> Void)?
    
    init(callbackQueue: OperationQueue = .main) {
        self.callbackQueue = callbackQueue
    }
    
    func start() {
        networker = Networker(depthCallback: { [weak self] result in
            switch result {
            case let .success(response):
                self?.handleDepth(response: response)
            case let .failure(error):
                self?.handle(error: error)
            }
        }, aggTradeCallback: { [weak self] result in
            switch result {
            case let .success(answer):
                self?.handleAggTrade(answer: answer)
            case let .failure(error):
                self?.handle(error: error)
            }
        }, callbackQueue: processingQueue)
        
        fetchDepthSnapshot()
    }
    
    private func fetchDepthSnapshot() {
        networker.fetchDepthSnapshot { [weak self] result in
            switch result {
            case let .success(snapshot):
                self?.lastUpdateID = snapshot.lastUpdateId
            case .failure:
                // TODO: handle
                print("failure")
            }
        }
    }
}

// MARK: Handle responses
private extension Store {
    func handle(error: Networker.NetworkerError?) {
//        switch error {
//        case let .unsupported(errMsg):
//            print(errMsg)
//        case let .receiving(err):
//            print(err.localizedDescription)
//        case let .sendFailed(err):
//            print(err.localizedDescription)
//        case let .socketShutdown(errMsg):
//            print(errMsg)
//        case nil:
//            print("")
//        }
    }
    
    private func handleDepth(response: DepthResponse) {
                
        guard let lastUpdateID = lastUpdateID,
            response.u > lastUpdateID else {
            return
        }
        
        if response.U <= lastUpdateID + 1,
            response.u >= lastUpdateID + 1 {
                // first event
        } else if let lastResponse = depthResponses.last,
            lastResponse.u + 1 == response.U {
                // all subsequent events, except first
        } else {
            resync()
            return
        }

        depthResponses.append(response)
        if depthResponses.count > Const.depthResponsesBufferSize {
            depthResponses.removeFirst()
        }
        
        var bidOrders: [Order] = []
        var askOrders: [Order] = []
        
        var iterator = depthResponses.reversed().makeIterator()
        while bidOrders.count <= Const.depthRecordsCount,
            askOrders.count <= Const.depthRecordsCount,
            let resp = iterator.next() {
                let bids = resp.bids.compactMap { bid -> Order? in
                    bid.quantity > 0 ? bid : nil
                }
                bidOrders += bids[0..<min(Const.depthRecordsCount - bidOrders.count, bids.count)]
                
                let asks = resp.asks.compactMap { ask -> Order? in
                    ask.quantity > 0 ? ask : nil
                }
                askOrders += asks[0..<min(Const.depthRecordsCount - askOrders.count, asks.count)]
        }
        
        let records = depthRecords(from: bidOrders, asks: askOrders)

        callbackQueue.addOperation { [weak self] in
            self?.orderBookCallback?(.success(records))
        }
    }
    
    private func depthRecords(from bids: [Order], asks: [Order]) -> [Record] {
        var records: [Record] = []
        for i in 0..<max(bids.count, asks.count) {
            var bid: Order?
            var ask: Order?
            if i < bids.count {
                bid = bids[i]
            }
            if i < asks.count {
                ask = asks[i]
            }
            records.append(Record(bid: bid,
                                  ask: ask))
        }
        return records
    }
    
    private func handleAggTrade(answer: AggregatedTrade) {
        guard let price = Double(answer.p),
            let quantity = Double(answer.q) else {
            print("AggTrade: price or quantity parsing failure")
            return
        }
        
        
        var priceChange = HistoryRecord.PriceChange.raise
        if let topRecord = historyRecords.first,
            price > topRecord.price {
            priceChange = .fall
        }
        let record = HistoryRecord(time: answer.T,
                                   price: price,
                                   quantity: quantity,
                                   priceChange: priceChange)
        
        var records = historyRecords
        records.insert(record, at: 0)
        if records.count > histiryRecordsMaxCapacity {
            records.removeLast()
        }
        historyRecords = records
        
        callbackQueue.addOperation { [weak self] in
            self?.marketHistoryCallback?(.success(records))
        }
    }
    
    private func resync() {
        lastUpdateID = nil
        depthResponses.removeAll()
        fetchDepthSnapshot()
        networker.stopListeningToDepth { [weak self] error in
            guard error == nil else {
                print("failed to unsubscribe from depth steam")
                return
            }
            
            self?.networker.listenToDepth(completion: { e in
                if e != nil {
                    print("failed to subscribe to depth stream")
                }
            })
        }
    }
}
