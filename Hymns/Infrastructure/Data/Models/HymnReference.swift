import Foundation
import GRDB

struct HymnReference {
    let hymnIdEntity: HymnIdEntity
    let hymnEntity: HymnEntity
}

extension HymnReference: Equatable {}

extension HymnReference: FetchableRecord {
    init(row: GRDB.Row) {
        // Intended force-trys. FetchableRecord is designed for records that reliably decode from rows.
        // swiftlint:disable:next force_try
        self.hymnIdEntity = try! HymnIdEntity.init(row: row)
        self.hymnEntity = HymnEntity.init(row: row)
    }
}
