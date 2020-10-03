import Foundation

private enum Const {
    static let dataIsNotSupported = "data listening is unsupported"
    static let unknownResponse = "type of response is unknown"
}

protocol WebSocketProtocol {
    typealias WebSocketCallback = (Result<String, WebSocketError>) -> Void
    
    init(url: URL,
         session: URLSession,
         callback: @escaping WebSocketCallback)
    func send(_ message: String)
}

enum WebSocketError: Error {
    case unsupported(String)
    case receiving(Error)
    case sendFailed(Error)
}

class WebSocket: WebSocketProtocol {
    private let session: URLSession
    private let connection: URLSessionWebSocketTask
    private let callback: WebSocketCallback
    
    required init(url: URL, session: URLSession, callback: @escaping WebSocketCallback) {
        self.session = session
        connection = session.webSocketTask(with: url)
        self.callback = callback
        listen()
    }
    
    deinit {
        connection.cancel()
    }
    
    private func listen() {
        connection.receive { [weak self] result in
            guard let self = self else { return }
            defer { self.listen() }
            
            do {
                let message = try result.get()
                switch message {
                case let .string(string):
                    self.callback(.success(string))
                case .data:
                    // was not able to figure out how to configure
                    // to recive data instead of strings (seems it isn't supported)
                    self.callback(.failure(WebSocketError.data))
                @unknown default:
                    self.callback(.failure(WebSocketError.unknownType))
                }
            } catch {
                self.callback(.failure(.receiving(error)))
            }
        }
        connection.resume()
    }
    
    func send(_ message: String) {
        self.connection.send(.string(message)) { [weak self] error in
            if let error = error {
                self?.callback(.failure(.sendFailed(error)))
            }
        }
    }
}

private extension WebSocketError {
    static var data = unsupported(Const.dataIsNotSupported)
    static var unknownType = unsupported(Const.unknownResponse)
}
