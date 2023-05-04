import Foundation
import GRDB

struct ScriptureEntity: Decodable, Equatable {
    let title: String
    let hymnType: HymnType
    let hymnNumber: String
    let scriptures: String

    enum CodingKeys: String, CodingKey {
        case title = "SONG_TITLE"
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case scriptures = "SONG_META_DATA_SCRIPTURES"
    }
}

extension ScriptureEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Many hymn titles prepend "Hymn: " to the title. It is unnecessary and takes up screen space, so  we
        // strip it out whenever possible.
        title = try container.decode(String.self, forKey: .title).replacingOccurrences(of: "Hymn: ", with: "")
        hymnType = try container.decode(HymnType.self, forKey: .hymnType)
        hymnNumber = try container.decode(String.self, forKey: .hymnNumber)
        scriptures = try container.decode(String.self, forKey: .scriptures)
    }
}
