import Foundation

private enum Const {
    static let dataIsNotSupported = "data listening is unsupported"
    static let unknownResponse = "type of response is unknown"
}

class WebSocket {
    enum WebSocketError: Error {
        case unsupported(String)
        case receiving(Error)
        case sendFailed(Error)
    }
    
    private let session: URLSession
    private let connection: URLSessionWebSocketTask
    private let callback: WebSocketCallback
    
    typealias WebSocketCallback = (Result<String, WebSocketError>) -> Void
    
    init(url: URL,
         session: URLSession,
         callback: @escaping WebSocketCallback) {
        self.session = session
        connection = session.webSocketTask(with: url)
        self.callback = callback
        listen()
        connection.resume()
    }
    
    deinit {
        connection.cancel()
    }
    
    private func listen() {
        connection.receive { [weak self] result in
            defer { self?.listen() }
            
            guard let self = self else { return }
            do {
                let message = try result.get()
                switch message {
                case let .string(string):
                    self.callback(.success(string))
                case .data:
                    self.callback(.failure(.data))
                @unknown default:
                    self.callback(.failure(.unknownType))
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

private extension WebSocket.WebSocketError {
    static var data = WebSocket.WebSocketError.unsupported(Const.dataIsNotSupported)
    static var unknownType = WebSocket.WebSocketError.unsupported(Const.unknownResponse)
}

