import Foundation
import GRDB

struct SongLink {
    let reference: HymnIdentifier
    let name: String
}

extension SongLink: Equatable {}

extension SongLink: Codable {}
