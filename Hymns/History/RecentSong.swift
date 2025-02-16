import Foundation
import RealmSwift

class RecentSong: Object {
    @objc dynamic var primaryKey: String!
    @objc dynamic var hymnIdentifier: HymnIdentifierWrapper!
    @objc dynamic var songTitle: String?

    override required init() {
        super.init()
    }

    init(hymnIdentifier: HymnIdentifierWrapper, songTitle: String?) {
        super.init()
        self.primaryKey = "\(hymnIdentifier.hymnType):\(hymnIdentifier.hymnNumber)"
        self.hymnIdentifier = hymnIdentifier
        self.songTitle = songTitle
    }

    convenience init(hymnIdentifier: HymnIdentifier, songTitle: String?) {
        self.init(hymnIdentifier: HymnIdentifierWrapper(hymnIdentifier), songTitle: songTitle)
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    override func isEqual(_ object: Any?) -> Bool {
        return primaryKey == (object as? RecentSong)?.primaryKey && hymnIdentifier == (object as? RecentSong)?.hymnIdentifier && songTitle == (object as? RecentSong)?.songTitle
    }

    override var hash: Int {
        primaryKey.hash + hymnIdentifier.hash + (songTitle?.hash ?? 0)
    }

    func copy() -> RecentSong {
        return RecentSong(hymnIdentifier: hymnIdentifier.hymnIdentifier, songTitle: songTitle)
    }
}

class RecentSongEntity: Object {
    @objc dynamic var primaryKey: String!
    @objc dynamic var recentSong: RecentSong!
    @objc dynamic var created: Date!

    override required init() {
        super.init()
    }

    init(recentSong: RecentSong, created: Date) {
        super.init()
        self.primaryKey = recentSong.primaryKey
        self.recentSong = recentSong
        self.created = created
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }
}
