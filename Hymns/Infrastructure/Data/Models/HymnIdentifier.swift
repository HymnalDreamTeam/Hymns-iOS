import Foundation
import RealmSwift

/**
 * Uniquely identifies a hymn.
 */
struct HymnIdentifier {
    let hymnType: HymnType
    let hymnNumber: String
    let queryParams: [String: String]?
    var queryParamString: String {
        guard let queryParams = queryParams else {
            return ""
        }
        return queryParams.serializeToQueryParamString ?? ""
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    var serializeToQueryParamString: String? {
        guard !self.isEmpty else {
            return nil
        }
        var str = "?"
        for (index, (key, value)) in self.enumerated() {
            if index > 0 {
                str += "&"
            }
            str += "\(key)=\(value)"
        }
        return str
    }
}

extension HymnIdentifier {

    // Allows us to use a customer initializer along with the default memberwise one
    // https://www.hackingwithswift.com/articles/106/10-quick-swift-tips
    init(hymnType: HymnType, hymnNumber: String) {
        self.hymnType = hymnType
        self.hymnNumber = hymnNumber
        self.queryParams = nil
    }

    init(_ entity: HymnIdentifierEntity) {
        self.hymnType = entity.hymnType
        self.hymnNumber = entity.hymnNumber
        self.queryParams = entity.queryParams?.deserializeFromQueryParamString
    }
}

extension HymnIdentifier: Hashable {
    static func == (lhs: HymnIdentifier, rhs: HymnIdentifier) -> Bool {
        lhs.hymnType == rhs.hymnType && lhs.hymnNumber == rhs.hymnNumber && lhs.queryParams == rhs.queryParams
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hymnType)
        hasher.combine(hymnNumber)
        hasher.combine(queryParams)
    }
}

enum SerializationError: Error {
    case deserialization
}

extension String {

    /**
     * Ties to deserialize a query param string (e.g. ?key1=a&key2=b) into a dictionary (e.g. ["key1: "a", "key2": "b"])
     */
    var deserializeFromQueryParamString: [String: String]? {
        do {
            // remove the leading "?" in the query param string if it exists
            return try replacingOccurrences(of: "?", with: "")
                // separate the key-value pairs
                .components(separatedBy: "&")
                // separate each pair into an array that looks like [key, value]
                .map({ component -> [String] in
                    component.components(separatedBy: "=")
                }).compactMap({ components throws -> (key: String, value: String) in
                    if components.count != 2 {
                        throw SerializationError.deserialization
                    }
                    return (key: components[0], value: components[1])
                }).reduce(into: [String: String](), { (result, arg1) in
                    let (key, value) = arg1
                    result[key] = value
                })
        } catch {
            return nil
        }
    }
}

class HymnIdentifierEntity: Object {
    // https://stackoverflow.com/questions/29123245/using-enum-as-property-of-realm-model
    @objc dynamic private var hymnTypeRaw = HymnType.classic.rawValue
    var hymnType: HymnType {
        get {
            return HymnType(rawValue: hymnTypeRaw)!
        }
        set {
            hymnTypeRaw = newValue.rawValue
        }
    }
    @objc dynamic var hymnNumber: String = ""
    @objc dynamic var queryParams: String?

    override required init() {
        super.init()
    }

    init(_ hymnIdentifier: HymnIdentifier) {
        super.init()
        self.hymnType = hymnIdentifier.hymnType
        self.hymnNumber = hymnIdentifier.hymnNumber
        self.queryParams = hymnIdentifier.queryParamString
    }

    override func isEqual(_ object: Any?) -> Bool {
        return hymnType == (object as? HymnIdentifierEntity)?.hymnType && hymnNumber == (object as? HymnIdentifierEntity)?.hymnNumber && queryParams == (object as? HymnIdentifierEntity)?.queryParams
    }

    override var hash: Int {
        return hymnType.abbreviatedValue.hash + hymnNumber.hash + (queryParams?.hash ?? 0)
    }
}
