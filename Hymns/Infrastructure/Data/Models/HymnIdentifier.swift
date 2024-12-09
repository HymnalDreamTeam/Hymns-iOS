import Foundation
import RealmSwift

/**
 * Uniquely identifies a hymn.
 */
struct HymnIdentifier: Equatable, Hashable {
    let hymnType: HymnType
    let hymnNumber: String
}

extension HymnIdentifier {
    init?(hymnType: HymnType?, hymnNumber: String) {
        guard let hymnType = hymnType else {
            return nil
        }
        self.hymnType = hymnType
        self.hymnNumber = hymnNumber
    }
}

extension HymnIdentifier: CustomStringConvertible {
    var description: String {
        "hymnType: \(hymnType), hymnNumber: \(hymnNumber)"
    }
}

extension HymnIdentifier {
    var displayTitle: String {
        String(format: hymnType.displayLabel, hymnNumber)
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

extension HymnIdentifier {

    // Allows us to use a customer initializer along with the default memberwise one
    // https://www.hackingwithswift.com/articles/106/10-quick-swift-tips
    init(entity: HymnIdentifierEntity) {
        self.hymnType = entity.hymnType
        self.hymnNumber = entity.hymnNumber
    }

    var toEntity: HymnIdentifierEntity {
        HymnIdentifierEntity(hymnIdentifier: self)
    }
}

extension HymnIdentifier {

    init(wrapper: HymnIdentifierWrapper) {
        self.hymnType = wrapper.hymnType
        self.hymnNumber = wrapper.hymnNumber
    }

    var toWrapper: HymnIdentifierWrapper {
        HymnIdentifierWrapper(self)
    }
}

// Wrapper for writing into Realm
class HymnIdentifierWrapper: Object {
    // https://stackoverflow.com/questions/29123245/using-enum-as-property-of-realm-model
    @objc dynamic private var hymnTypeRaw = HymnType.classic.abbreviatedValue
    var hymnType: HymnType {
        get {
            return HymnType.fromAbbreviatedValue(hymnTypeRaw)!
        }
        set {
            hymnTypeRaw = newValue.abbreviatedValue
        }
    }
    @objc dynamic var hymnNumber: String = ""

    var hymnIdentifier: HymnIdentifier {
        get {
            HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
        }
        set {
            hymnTypeRaw = newValue.hymnType.abbreviatedValue
            hymnNumber = newValue.hymnNumber
        }
    }

    override required init() {
        super.init()
    }

    init(_ hymnIdentifier: HymnIdentifier) {
        super.init()
        self.hymnType = hymnIdentifier.hymnType
        self.hymnNumber = hymnIdentifier.hymnNumber
    }

    override func isEqual(_ object: Any?) -> Bool {
        return hymnType == (object as? HymnIdentifierWrapper)?.hymnType && hymnNumber == (object as? HymnIdentifierWrapper)?.hymnNumber
    }

    override var hash: Int {
        return hymnType.abbreviatedValue.hash + hymnNumber.hash
    }
}

extension HymnIdentifierEntity {
    init(hymnIdentifier: HymnIdentifier) {
        self.hymnType = hymnIdentifier.hymnType
        self.hymnNumber = hymnIdentifier.hymnNumber
    }

    var toHymnIdentifier: HymnIdentifier {
        HymnIdentifier(entity: self)
    }
}
