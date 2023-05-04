import Foundation
import RealmSwift

/**
 * Uniquely identifies a hymn.
 */
struct HymnIdentifier {
    let hymnType: HymnType
    let hymnNumber: String
}

extension HymnIdentifier {

    // Allows us to use a customer initializer along with the default memberwise one
    // https://www.hackingwithswift.com/articles/106/10-quick-swift-tips
    init(_ entity: HymnIdentifierEntity) {
        self.hymnType = entity.hymnType
        self.hymnNumber = entity.hymnNumber
    }
}

extension HymnIdentifier: Hashable {
    static func == (lhs: HymnIdentifier, rhs: HymnIdentifier) -> Bool {
        lhs.hymnType == rhs.hymnType && lhs.hymnNumber == rhs.hymnNumber
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hymnType)
        hasher.combine(hymnNumber)
    }
}

extension HymnIdentifier: CustomStringConvertible {
    var description: String {
        "hymnType: \(hymnType), hymnNumber: \(hymnNumber)"
    }
}

extension HymnIdentifier: Codable {

    enum CodingKeys: String, CodingKey {
        case hymnType
        case hymnNumber
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hymnType.rawValue, forKey: .hymnType)
        try container.encode(hymnNumber, forKey: .hymnNumber)
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

    override required init() {
        super.init()
    }

    init(_ hymnIdentifier: HymnIdentifier) {
        super.init()
        self.hymnType = hymnIdentifier.hymnType
        self.hymnNumber = hymnIdentifier.hymnNumber
    }

    override func isEqual(_ object: Any?) -> Bool {
        return hymnType == (object as? HymnIdentifierEntity)?.hymnType && hymnNumber == (object as? HymnIdentifierEntity)?.hymnNumber
    }

    override var hash: Int {
        return hymnType.abbreviatedValue.hash + hymnNumber.hash
    }
}
