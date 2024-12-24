import Foundation
import GRDB

/**
 * Structure of a Hymn object returned from the databse.
 */
struct HymnIdEntity: Equatable {

    let hymnType: HymnType
    let hymnNumber: String
    let songId: Int64
    var hymnIdentifier: HymnIdentifier? {
        HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
    }

    init(hymnType: HymnType, hymnNumber: String, songId: Int64) {
        self.hymnType = hymnType
        self.hymnNumber = hymnNumber
        self.songId = songId
    }

    init(hymnIdentifier: HymnIdentifier, songId: Int64) {
        self.init(hymnType: hymnIdentifier.hymnType, hymnNumber: hymnIdentifier.hymnNumber, songId: songId)
    }

    // https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    enum CodingKeys: String, CodingKey {
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case songId = "SONG_ID"
    }

    static func == (lhs: HymnIdEntity, rhs: HymnIdEntity) -> Bool {
        let hymnTypesEqual = lhs.hymnType == rhs.hymnType
        let hymnNumbersEqual = lhs.hymnNumber == rhs.hymnNumber
        let songIdsEqual = lhs.songId == rhs.songId
        return hymnTypesEqual && hymnNumbersEqual && songIdsEqual
    }

    func toBuilder() -> HymnIdEntityBuilder {
        HymnIdEntityBuilder(hymnType: hymnType, hymnNumber: hymnNumber, songId: songId)
    }
}

extension HymnIdEntity: Codable, FetchableRecord, MutablePersistableRecord {
    // https://github.com/groue/GRDB.swift/blob/master/README.md#conflict-resolution
    static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)

    // Define database columns from CodingKeys
    private enum Columns {
        static let hymnType = Column(CodingKeys.hymnType)
        static let hymnNumber = Column(CodingKeys.hymnNumber)
        static let songId = Column(CodingKeys.songId)
    }
}

extension HymnIdEntity: PersistableRecord {
    static let databaseTableName = "SONG_IDS"
}

class HymnIdEntityBuilder {

    private(set) var hymnType: HymnType
    private(set) var hymnNumber: String
    private(set) var songId: Int64

    init(hymnType: HymnType, hymnNumber: String, songId: Int64) {
        self.hymnType = hymnType
        self.hymnNumber = hymnNumber
        self.songId = songId
    }

    convenience init(hymnIdentifier: HymnIdentifier, songId: Int64) {
        self.init(hymnType: hymnIdentifier.hymnType, hymnNumber: hymnIdentifier.hymnNumber, songId: songId)
    }

    convenience init(_ hymnIdEntity: HymnIdEntity) {
        self.init(hymnType: hymnIdEntity.hymnType, hymnNumber: hymnIdEntity.hymnNumber, songId: hymnIdEntity.songId)
    }

    public func hymnIdentifier(_ hymnIdentifier: HymnIdentifier) -> HymnIdEntityBuilder {
        self.hymnType = hymnIdentifier.hymnType
        self.hymnNumber = hymnIdentifier.hymnNumber
        return self
    }

    public func songId(_ songId: Int64) -> HymnIdEntityBuilder {
        self.songId = songId
        return self
    }

    public func build() -> HymnIdEntity {
        HymnIdEntity(hymnType: hymnType, hymnNumber: hymnNumber, songId: songId)
    }
}
