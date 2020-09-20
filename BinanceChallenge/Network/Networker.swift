import Foundation

private enum Const {
    static let workerQueueName = "com.berkut89.binancechallenge.networker"
    static let baseURL = "wss://stream.binance.com:9443/ws/"
    static let snapshotURLFormat = "https://www.binance.com/api/v1/depth?symbol=%@&limit=1000"
    static let depthStream = "@depth"
    static let aggTradeStreeam = "@aggTrade"
}

class Networker: NSObject {
    enum NetworkerError: Error {
        // TODO: improve error handling
        case general(Error)
    }
        
    enum Symbol: String {
        case btcusdt = "btcusdt"
    }
    
    private enum MessageMethod: String {
        case subscribe = "SUBSCRIBE"
        case unsubscribe = "UNSUBSCRIBE"
    }
        
    private enum Stream: String {
        case aggTrade = "aggTrade"
        case depth = "depth"
    }
    
    private struct Message: Encodable {
        let method: String
        let params: [String]
        let id: UInt
        
        init(method: MessageMethod,
             symbol: Symbol,
             stream: Stream,
             id: UInt) {
            self.method = method.rawValue
            self.params = [[symbol.rawValue,
                            stream.rawValue].joined(separator: "@")]
            self.id = id
        }
    }
    
    private var session: URLSession?
    private let callbackQueue: OperationQueue!
    
    typealias depthCallback = (Result<DepthResponse, NetworkerError>) -> Void
    typealias aggTradeCallback = (Result<AggregatedTrade, NetworkerError>) -> Void
    
    private let depthStream: WebSocket
    private let aggTradeStream: WebSocket
    private let symbol: Symbol
    
    init(symbol: Symbol = .btcusdt,
         depthCallback: @escaping depthCallback,
         aggTradeCallback: @escaping aggTradeCallback,
         callbackQueue: OperationQueue = OperationQueue.main) {
        self.symbol = symbol
        self.session = URLSession(configuration: .default, delegate:nil, delegateQueue: callbackQueue)
        self.callbackQueue = callbackQueue
        let depthURL = URL(string: Const.baseURL + symbol.rawValue + Const.depthStream)!
        depthStream = WebSocket(url: depthURL, session: self.session!, callback: { result in
            switch result {
            case let .success(message):
                depthCallback(.success(message.decode()))
            case let .failure(error):
                depthCallback(.failure(.general(error)))
            }
        })
        
        let aggTradeURL = URL(string: Const.baseURL + symbol.rawValue + Const.aggTradeStreeam)!
        aggTradeStream = WebSocket(url: aggTradeURL, session: self.session!, callback: { result in
            switch result {
            case let .success(message):
                aggTradeCallback(.success(message.decode()))
            case let .failure(error):
                aggTradeCallback(.failure(.general(error)))
            }
        })
        
        super.init()
    }
    
    @available(*, unavailable)
    override init() {
        fatalError()
    }
    
    func fetchDepthSnapshot(completion: @escaping (Result<DepthSnapshot, Error>) -> Void) {
        let urlString = String(format: Const.snapshotURLFormat, symbol.rawValue.uppercased())
        guard let url = URL(string: urlString) else {
            fatalError("Could not create depth snapshot URL. Can't proceed further")
        }
        let task = session?.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(data.decode()))
        })
        task?.resume()
    }
            
    func listenToDepth() {
          let msg = message(type: .subscribe,
                            stream: .depth)
          depthStream.send(msg)
    }
      
    func stopListeningToDepth() {
        let msg = message(type: .unsubscribe,
                          stream: .depth)
        depthStream.send(msg)
    }
      
    func listenToAggregatedTrade() {
        let msg = message(type: .subscribe,
                          stream: .depth)
        aggTradeStream.send(msg)
    }
      
    func stopListeningToAggregatedTrade() {
        let msg = message(type: .unsubscribe,
                          stream: .aggTrade)
        aggTradeStream.send(msg)
    }
    
    private func message(type: MessageMethod,
                         stream: Stream) -> String {
        return Message(method: type,
                       symbol: symbol,
                       stream: stream,
                       id: 312).asJSONString // TODO: pass proper id
    }
}
