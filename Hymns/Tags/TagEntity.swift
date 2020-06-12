import SwiftUI
import RealmSwift

class TagEntity: Object, Identifiable {
    @objc dynamic var primaryKey: String!
    @objc dynamic var hymnIdentifierEntity: HymnIdentifierEntity!
    @objc dynamic var songTitle: String!
    @objc dynamic var tag: String!

    //https://stackoverflow.com/questions/29123245/using-enum-as-property-of-realm-model
    @objc private dynamic var privateTagColor: Int = TagColor.none.rawValue
    var tagColor: TagColor {
        get { return TagColor(rawValue: privateTagColor)! }
        set { privateTagColor = newValue.rawValue }
    }

    required init() {
        super.init()
    }

    init(hymnIdentifier: HymnIdentifier, songTitle: String, tag: String, tagColor: TagColor) {
        super.init()
        self.primaryKey = Self.createPrimaryKey(hymnIdentifier: hymnIdentifier, tag: tag)
        self.hymnIdentifierEntity = HymnIdentifierEntity(hymnIdentifier)
        self.songTitle = songTitle
        self.tag = tag
        self.tagColor = tagColor
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    static func createPrimaryKey(hymnIdentifier: HymnIdentifier, tag: String) -> String {
        return ("\(hymnIdentifier.hymnType):\(hymnIdentifier.hymnNumber):\(hymnIdentifier.queryParams ?? [String: String]()):\(tag)")
    }

    override func isEqual(_ object: Any?) -> Bool {
        return primaryKey == (object as? TagEntity)?.primaryKey
    }

    override var hash: Int {
        return primaryKey.hash
    }
}

enum TagColor: Int {
    case none, blue, green, yellow, red
}

extension TagColor {
    var background: Color {
        switch self {
        case .none:
            return Color(.systemBackground)
        case .blue:
            return CustomColors.backgroundBlue
        case .green:
            return CustomColors.backgroundGreen
        case .yellow:
            return CustomColors.backgroundYellow
        case .red:
            return CustomColors.backgroundRed
        }
    }

    var foreground: Color {
        switch self {
        case .none:
            return Color.primary
        case .blue:
            return CustomColors.foregroundBlue
        case .green:
            return CustomColors.foregroundGreen
        case .yellow:
            return CustomColors.foregroundYellow
        case .red:
            return CustomColors.foregroundRed
        }
    }
}
