import RealmSwift

class Tag: Object, Identifiable {
    @objc dynamic var primaryKey: String!
    @objc dynamic var hymnIdentifierEntity: HymnIdentifierEntity!
    @objc dynamic var songTitle: String!
    @objc dynamic var tag: String!

    // https://stackoverflow.com/questions/29123245/using-enum-as-property-of-realm-model
    @objc private dynamic var privateTagColor: Int = TagColor.none.rawValue
    var color: TagColor {
        get { return TagColor(rawValue: privateTagColor)! }
        set { privateTagColor = newValue.rawValue }
    }

    override required init() {
        super.init()
    }

    init(hymnIdentifier: HymnIdentifier, songTitle: String, tag: String, color: TagColor) {
        super.init()
        self.primaryKey = Self.createPrimaryKey(hymnIdentifier: hymnIdentifier, tag: tag, color: color)
        self.hymnIdentifierEntity = HymnIdentifierEntity(hymnIdentifier)
        self.songTitle = songTitle
        self.tag = tag
        self.color = color
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    static func createPrimaryKey(hymnIdentifier: HymnIdentifier, tag: String, color: TagColor) -> String {
        return "\(hymnIdentifier.hymnType):\(hymnIdentifier.hymnNumber):\(tag):\(color.rawValue)"
    }

    override func isEqual(_ object: Any?) -> Bool {
        return primaryKey == (object as? Tag)?.primaryKey
    }

    override var hash: Int {
        return primaryKey.hash
    }

    func copy() -> Tag {
        return Tag(hymnIdentifier: hymnIdentifierEntity.hymnIdentifier,
                   songTitle: songTitle, tag: tag, color: color)
    }
}

class TagEntity: Object {
    @objc dynamic var primaryKey: String!
    @objc dynamic var tagObject: Tag!
    @objc dynamic var created: Date!

    override required init() {
        super.init()
    }

    init(tagObject: Tag, created: Date) {
        super.init()
        self.primaryKey = tagObject.primaryKey
        self.tagObject = tagObject
        self.created = created
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    func copy() -> TagEntity {
        return TagEntity(tagObject: tagObject.copy(), created: created)
    }
}
