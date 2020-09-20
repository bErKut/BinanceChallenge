import Foundation

struct Record {
    let bid: Order
    let ask: Order
}

class Store: NSObject {
    private enum Const {
        static let processingQueue = "com.berkut89.binancechallenge.store"
    }
    
    private enum Symbol: String {
        case btcusdt = "btcusdt"
    }
    
    private var lastUpdateID: Int?
    private var lastDepthResponse: DepthResponse?
        
    var networker: Networker!
    var processingQueue: OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = Const.processingQueue
        return operationQueue
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
        guard let lastUpdateID = lastUpdateID else {
            print("nothig to campare against")
            return
        }
        
        // TODO: refactor
        if response.u > lastUpdateID  {
            if let lastResponse = lastDepthResponse,
                lastResponse.u + 1 == response.U {
                    // all subsequent events, except first
            } else if response.U <= lastUpdateID + 1,
                response.u >= lastUpdateID + 1 {
                    // handle case for first event
            } else {
                resync()
                return
            }
            
            lastDepthResponse = response
            
                
            // The first processed event should have U <= lastUpdateId+1 AND u >= lastUpdateId+1.
            //   "U": 157,           // First update ID in event
            //   "u": 160,           // Final update ID in event
        }

//        print(response)
    }
    
    private func handleAggTrade(answer: AggregatedTrade) {
//        print(answer)
    }
    
    private func resync() {
         // TODO
    }
}
