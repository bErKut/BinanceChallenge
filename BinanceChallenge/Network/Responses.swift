struct DepthResponse: Decodable {
    let u: Int
    let U: Int
    var bids: [Order] {
        return a.values
    }
    var asks: [Order] {
        return b.values
    }
    
    private let a: Order.List
    private let b: Order.List
}

struct AggregatedTrade: Decodable {
    let T: Int
    let p: String
    let q: String
}

struct DepthSnapshot: Decodable {
    let lastUpdateId: Int
}

struct Order: Decodable, Hashable {
    let quantity: Double
    let price: Double
}

private extension Order {
    struct List: Decodable {
        let values: [Order]
        
        init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                let list = try container.decode([[String]].self)
                values = list.compactMap { pair in
                    guard pair.count == 2,
                        let quantity = Double(pair[1]),
                        let price = Double(pair[0]) else {
                            return nil
                    }
                    return Order(quantity: quantity, price: price)
                }
            } catch {
                values = []
            }
        }
    }
}

struct MessageResponse: Decodable {
    let result: String?
    let id: Int
}
