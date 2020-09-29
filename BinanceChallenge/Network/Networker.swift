import Foundation

private enum Const {
    static let workerQueueName = "com.berkut89.binancechallenge.networker"
    static let baseURL = "wss://stream.binance.com:9443/ws/"
    static let snapshotURLFormat = "https://www.binance.com/api/v1/depth?symbol=%@&limit=1000"
    static let depthStream = "@depth"
    static let aggTradeStreeam = "@aggTrade"
}

class Networker {
    enum NetworkerError: Error {
        case snapshot(Error?)
        case depth(Error)
        case aggTrade(Error)
        case unsubscribe
        case subscribe
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
    
    private enum RequestId: Int {
        case unsubscribeDepth
        case subscribeDepth
        case `default`
    }
    
    private struct Message: Encodable {
        let method: String
        let params: [String]
        let id: Int
        
        init(method: MessageMethod,
             symbol: Symbol,
             stream: Stream,
             id: Int) {
            self.method = method.rawValue
            self.params = [[symbol.rawValue,
                            stream.rawValue].joined(separator: "@")]
            self.id = id
        }
    }
    
    private var session: URLSession?
    private let callbackQueue: OperationQueue!
    
    typealias DepthCallback = (Result<DepthResponse, NetworkerError>) -> Void
    typealias AggTradeCallback = (Result<AggregatedTrade, NetworkerError>) -> Void
    typealias MessageCallback = (NetworkerError?) -> Void
    
    private let depthCallback: DepthCallback
    private let aggTradeCallback: AggTradeCallback
    private var unsubscribeDepthCallback: MessageCallback?
    private var subscribeDepthCallback: MessageCallback?
    
    private var depthStream: WebSocketProtocol?
    private var aggTradeStream: WebSocketProtocol?
    private let symbol: Symbol
    private let baseURL: String
        
    init(symbol: Symbol = .btcusdt,
         depthCallback: @escaping DepthCallback,
         aggTradeCallback: @escaping AggTradeCallback,
         callbackQueue: OperationQueue = OperationQueue.main,
         baseURL: String = Const.baseURL) {
        self.symbol = symbol
        self.depthCallback = depthCallback
        self.aggTradeCallback = aggTradeCallback
        self.session = URLSession(configuration: .default, delegate:nil, delegateQueue: callbackQueue)
        self.callbackQueue = callbackQueue
        self.baseURL = baseURL
        
        start()
    }
    
    func start() {
        let depthURL = URL(string: baseURL + symbol.rawValue + Const.depthStream)!
        depthStream = WebSocket(url: depthURL, session: self.session!, callback: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(message):
                if let depth: DepthResponse = message.decode() {
                    self.depthCallback(.success(depth))
                } else if let messageResponse: MessageResponse = message.decode() {
                    self.handle(message: messageResponse)
                }
            case let .failure(error):
                self.depthCallback(.failure(.depth(error)))
            }
        })
        let aggTradeURL = URL(string: baseURL + symbol.rawValue + Const.aggTradeStreeam)!
        aggTradeStream = WebSocket(url: aggTradeURL, session: self.session!, callback: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(message):
                if let aggTrade: AggregatedTrade = message.decode() {
                    self.aggTradeCallback(.success(aggTrade))
                }
            case let .failure(error):
                self.aggTradeCallback(.failure(.aggTrade(error)))
            }
        })
    }
    
    func fetchDepthSnapshot(completion: @escaping (Result<DepthSnapshot, NetworkerError>) -> Void) {
        let urlString = String(format: Const.snapshotURLFormat, symbol.rawValue.uppercased())
        guard let url = URL(string: urlString) else {
            fatalError("Could not create depth snapshot URL. Can't proceed further")
        }
        let task = session?.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data,
                let snapshot: DepthSnapshot = data.decode() else {
                    completion(.failure(NetworkerError.snapshot(error)))
                    return
            }
            
            completion(.success(snapshot))
        })
        task?.resume()
    }
            
    func listenToDepth(completion: @escaping MessageCallback) {
        subscribeDepthCallback = completion
        let msg = message(type: .subscribe,
                          stream: .depth,
                          id: RequestId.subscribeDepth.rawValue)
        depthStream?.send(msg)
    }
      
    func stopListeningToDepth(completion: @escaping MessageCallback) {
        unsubscribeDepthCallback = completion
        let msg = message(type: .unsubscribe,
                          stream: .depth,
                          id: RequestId.unsubscribeDepth.rawValue)
        depthStream?.send(msg)
    }
      
    func listenToAggregatedTrade() {
        let msg = message(type: .subscribe,
                          stream: .depth)
        aggTradeStream?.send(msg)
    }
      
    func stopListeningToAggregatedTrade() {
        let msg = message(type: .unsubscribe,
                          stream: .aggTrade)
        aggTradeStream?.send(msg)
    }
    
    private func message(type: MessageMethod,
                         stream: Stream,
                         id: Int = RequestId.default.rawValue) -> String {
        return Message(method: type,
                       symbol: symbol,
                       stream: stream,
                       id: id).asJSONString
    }
}

extension Networker {
    func handle(message response: MessageResponse) {
        switch response.id {
        case RequestId.unsubscribeDepth.rawValue:
            let error = response.result == nil ? nil : NetworkerError.unsubscribe
            unsubscribeDepthCallback?(error)
            unsubscribeDepthCallback = nil
        case RequestId.subscribeDepth.rawValue:
            let error = response.result == nil ? nil : NetworkerError.subscribe
            subscribeDepthCallback?(error)
            subscribeDepthCallback = nil
        default:
            return
        }
    }
}
