import UIKit

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

extension UILabel {
    convenience init(text: String?,
                     textColor: UIColor = .white) {
        self.init(frame: .zero)
        self.text = text
        self.textColor = textColor
    }
}

extension Array where Element: NSLayoutConstraint {
    func activate() {
        NSLayoutConstraint.activate(self)
    }
}

extension UIColor {
    static var dark: UIColor { rgb(18, 21, 30) }
    static var golden: UIColor { rgb(193, 172, 88) }
    static var pale: UIColor { rgb(63, 69, 78) }
    static var paleLight: UIColor { rgb(102, 106, 114) }
    private static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.fill(CGRect(origin: .zero, size: size))
        guard
            let image = UIGraphicsGetImageFromCurrentImageContext(),
            let imagePNGData = image.pngData()
            else { return nil }
        UIGraphicsEndImageContext()

        self.init(data: imagePNGData)
   }
}
