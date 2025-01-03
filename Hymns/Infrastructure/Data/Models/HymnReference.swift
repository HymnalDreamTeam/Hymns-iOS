import Foundation
import GRDB

struct HymnReference {
    let hymnIdEntity: HymnIdEntity
    let hymnEntity: HymnEntity
}

extension HymnReference: Equatable {}

extension HymnReference: FetchableRecord {
    init(row: GRDB.Row) {
        self.hymnIdEntity = try! HymnIdEntity.init(row: row)
        self.hymnEntity = HymnEntity.init(row: row)
    }
}
