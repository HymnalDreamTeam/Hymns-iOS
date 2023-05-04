import SwiftUI
import RealmSwift

class FavoriteEntity: Object, Identifiable {
    @objc dynamic var primaryKey: String!
    @objc dynamic var hymnIdentifierEntity: HymnIdentifierEntity!
    @objc dynamic var songTitle: String!

    override required init() {
        super.init()
    }

    init(hymnIdentifier: HymnIdentifier, songTitle: String) {
        super.init()
        self.primaryKey = Self.createPrimaryKey(hymnIdentifier: hymnIdentifier)
        self.hymnIdentifierEntity = HymnIdentifierEntity(hymnIdentifier)
        self.songTitle = songTitle
    }

    init(hymnIdentifier: HymnIdentifier) {
        super.init()
        self.primaryKey = Self.createPrimaryKey(hymnIdentifier: hymnIdentifier)
        self.hymnIdentifierEntity = HymnIdentifierEntity(hymnIdentifier)
        self.songTitle = ""
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    static func createPrimaryKey(hymnIdentifier: HymnIdentifier) -> String {
        return "\(hymnIdentifier.hymnType):\(hymnIdentifier.hymnNumber)"
    }

    override func isEqual(_ object: Any?) -> Bool {
        return primaryKey == (object as? FavoriteEntity)?.primaryKey
    }

    override var hash: Int {
        return primaryKey.hash
    }
}
