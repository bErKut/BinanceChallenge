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

struct AggregatedTrade: Codable {
    let T: Int
    let p: String
    let q: String
}

struct DepthSnapshot: Codable {
    let lastUpdateId: Int
}

struct Order: Codable {
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
                    guard let quantity = Double(pair[1]),
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
