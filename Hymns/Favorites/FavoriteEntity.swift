import SwiftUI
import RealmSwift

class FavoriteEntity: Object, Identifiable {
    @objc dynamic var primaryKey: String!
    @objc dynamic var hymnIdentifier: HymnIdentifierWrapper!
    @objc dynamic var songTitle: String?

    override required init() {
        super.init()
    }

    init(hymnIdentifier: HymnIdentifierWrapper, songTitle: String?) {
        super.init()
        self.primaryKey = Self.createPrimaryKey(hymnIdentifier: hymnIdentifier)
        self.hymnIdentifier = hymnIdentifier
        self.songTitle = songTitle
    }

    convenience init(hymnIdentifier: HymnIdentifier, songTitle: String?) {
        self.init(hymnIdentifier: HymnIdentifierWrapper(hymnIdentifier), songTitle: songTitle)
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    static func createPrimaryKey(hymnIdentifier: HymnIdentifier) -> String {
        return createPrimaryKey(hymnIdentifier: HymnIdentifierWrapper(hymnIdentifier))
    }

    static func createPrimaryKey(hymnIdentifier: HymnIdentifierWrapper) -> String {
        return "\(hymnIdentifier.hymnType):\(hymnIdentifier.hymnNumber)"
    }

    override func isEqual(_ object: Any?) -> Bool {
        return primaryKey == (object as? FavoriteEntity)?.primaryKey
    }

    override var hash: Int {
        return primaryKey.hash
    }

    func copy() -> FavoriteEntity {
        return FavoriteEntity(hymnIdentifier: hymnIdentifier, songTitle: songTitle)
    }
}
