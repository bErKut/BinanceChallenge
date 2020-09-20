import Foundation

extension Encodable {
    var asJSONString: String {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(self),
            let json = String(data: jsonData, encoding: .utf8) else {
            fatalError("JSON for message creation has failed")
        }
        return json
    }
}

extension String {
    func decode<T: Decodable>() -> T {
        guard let jsonData = data(using: .utf8) else {
            fatalError("Could not create data from string")
        }
        return jsonData.decode()
    }
}

extension Data {
    func decode<T: Decodable>() -> T {
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(T.self, from: self) else {
            fatalError("Could not decode json data to expected structure")
        }
        return result
    }
}

//func decode<T: Decodable>(string: String) -> T {
//    guard let jsonData = string.data(using: .utf8) else {
//        fatalError("Could not create data from string")
//    }
//    return decode(data: jsonData)
//}

//func decode<T: Decodable>(data: Data) -> T {
//    let decoder = JSONDecoder()
//    guard let result = try? decoder.decode(T.self, from: data) else {
//        fatalError("Could not decode json data to expected structure")
//    }
//    return result
//}

