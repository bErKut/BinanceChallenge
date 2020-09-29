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
    func decode<T: Decodable>() -> T? {
        return data(using: .utf8)?.decode()
    }
}

extension Data {
    func decode<T: Decodable>() -> T? {
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(T.self, from: self) else {
            return nil
        }
        return result
    }
}

extension UILabel {
    convenience init(text: String? = nil,
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
    static var emerald: UIColor { rgb(94, 169, 141) }
    static var reddish: UIColor { rgb(146, 57, 66) }
    
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

extension NumberFormatter {
    private enum Const {
        static let quantityFractionDigits = 6
        static let groupingSeparator = " "
        static let decimalSeparator = ","
    }
    
    static let quantityFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = Const.decimalSeparator
        formatter.minimumFractionDigits = Const.quantityFractionDigits
        formatter.maximumFractionDigits = Const.quantityFractionDigits
        return formatter
    }()
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = Const.groupingSeparator
        formatter.decimalSeparator = Const.decimalSeparator
        return formatter
    }()
}

extension DateComponentsFormatter {
    static let time: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter
    }()
}

extension UICollectionViewCompositionalLayout {
    private enum Const {
        static let cellHeight: CGFloat = 28
    }
    static var list: UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(Const.cellHeight)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
