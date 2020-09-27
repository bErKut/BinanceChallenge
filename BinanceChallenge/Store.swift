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
    let time: String
    let price: String
    let quantity: String
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
    }
    
    private enum Symbol: String {
        case btcusdt = "btcusdt"
    }
    
    private var lastUpdateID: Int?
    private var lastDepthResponse: DepthResponse?
    private var historyRecords: [HistoryRecord] = []
    private var histiryRecordsMaxCapacity = Const.historyRecordsMaxCount
        
    private var networker: Networker!
    private var processingQueue: OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = Const.processingQueue
        return operationQueue
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
        
        // TODO: refactor
        if let lastResponse = lastDepthResponse,
            lastResponse.u + 1 == response.U {
                // all subsequent events, except first
        } else if response.U <= lastUpdateID + 1,
            response.u >= lastUpdateID + 1 {
                // handle case for first event
        } else {
            resync()
            lastDepthResponse = response
            return
        }
        
        lastDepthResponse = response
        
        var records: [Record] = []
        for i in 0..<max(response.asks.count, response.bids.count) {
            var bidOrder: Order?
            var askOrder: Order?
            if i < response.bids.count {
                bidOrder = response.bids[i]
            }
            if i < response.asks.count {
                askOrder = response.asks[i]
            }
            records.append(Record(bid: bidOrder, ask: askOrder))
        }
        
        callbackQueue.addOperation { [weak self] in
            self?.orderBookCallback?(.success(records))
        }
    }
    
    private func handleAggTrade(answer: AggregatedTrade) {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        let date = Date(timeIntervalSince1970: TimeInterval(answer.T/1_000))
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        guard let timeString = formatter.string(from: components) else { return }
        let record = HistoryRecord(time: timeString,
                                   price: answer.p,
                                   quantity: answer.q)
        
        var records = historyRecords
        records.insert(record, at: 0)
        if records.count > histiryRecordsMaxCapacity {
            records = records.dropLast()
        }
        historyRecords = records
        
        callbackQueue.addOperation { [weak self] in
            self?.marketHistoryCallback?(.success(records))
        }
    }
    
    private func resync() {
        print("resync")
         // TODO
    }
}
